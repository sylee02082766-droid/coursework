clear; clc; close all; rng(7)

cfg.dt = 1;
cfg.pathInterval = 50;
cfg.origin = [183000 546000];
cfg.wp = [183679 550875; 187404 551700; 190583 550056; 191857 549643; 193093 546814] - cfg.origin;
cfg.rx = [186520 550560 130; 190420 548310 42; 191720 548310 75; 185880 551690 28; 193670 549440 15; 187820 552810 130; 195620 548310 25; 191720 550560 228; 190420 550560 150; 185880 549440 45; 185230 550560 110] - [cfg.origin 0];
cfg.ref = 1;
cfg.sigmaA = 2;
cfg.sigmaRange = 6;
cfg.sigmaNlos = 20;
cfg.biasMin = 25;
cfg.biasMax = 90;
cfg.gate = 3 * cfg.sigmaRange;
cfg.adaptiveRScale = 30;
cfg.Np = 1500;
cfg.rough = [8 8 0.8 0.8];

[truth, t] = makeTruth(cfg);
buildings = loadBuildings(cfg, truth);

scenarios = [
    struct("name","LOS_TDOA",          "alt",450,"kind","los",     "p",0.00)
    struct("name","Random_NLOS",       "alt",450,"kind","random",  "p",0.15)
    struct("name","Building_NLOS_300m","alt",300,"kind","building","p",0.02)
    struct("name","Building_NLOS_450m","alt",450,"kind","building","p",0.02)
    struct("name","Building_NLOS_600m","alt",600,"kind","building","p",0.02)
];

[F, Q] = motion(cfg);
rows = {};
result = struct("sc",{}, "xe",{}, "xp",{}, "ee",{}, "ep",{}, "vis",{});
for s = 1:numel(scenarios)
    sc = scenarios(s);
    cfg.alt = sc.alt;
    [z, vis] = makeMeas(truth, buildings, sc, cfg);
    x0 = truth(1,:)' + [20; -15; 1; -1];
    P0 = diag([60 60 6 6].^2);
    xe = ekf(z, x0, P0, F, Q, cfg);
    xp = pf(z, x0, P0, F, Q, cfg);
    ee = hypot(xe(:,1)-truth(:,1), xe(:,2)-truth(:,2));
    ep = hypot(xp(:,1)-truth(:,1), xp(:,2)-truth(:,2));
    rows(end+1,:) = makeRow(sc, "EKF", ee, vis);
    rows(end+1,:) = makeRow(sc, "PF", ep, vis);
    result(s).sc = sc;
    result(s).xe = xe;
    result(s).xp = xp;
    result(s).ee = ee;
    result(s).ep = ep;
    result(s).vis = vis;
end

metrics = cell2table(rows, "VariableNames", ["Scenario","Filter","Altitude_m","Mean_m","RMSE_m","P95_m","Max_m","Mean_LOS","NLOS_Ratio"]);
disp(metrics)
plotTrajectory(truth, result(1).xe, result(1).xp, buildings, result(1).sc, cfg)
for s = 1:numel(result)
    plotError(t, result(s))
end

function [x, t] = makeTruth(cfg)
d = [0; cumsum(hypot(diff(cfg.wp(:,1)), diff(cfg.wp(:,2))))];
q = linspace(0, d(end), ceil(d(end) / cfg.pathInterval) + 1)';
p = [pchip(d, cfg.wp(:,1), q), pchip(d, cfg.wp(:,2), q)];
vx = zeros(size(q));
vy = zeros(size(q));
vx(1) = (p(2,1) - p(1,1)) / cfg.dt;
vy(1) = (p(2,2) - p(1,2)) / cfg.dt;
vx(end) = (p(end,1) - p(end-1,1)) / cfg.dt;
vy(end) = (p(end,2) - p(end-1,2)) / cfg.dt;
vx(2:end-1) = (p(3:end,1) - p(1:end-2,1)) / (2 * cfg.dt);
vy(2:end-1) = (p(3:end,2) - p(1:end-2,2)) / (2 * cfg.dt);
x = [p vx vy];
t = (0:size(x,1)-1)' * cfg.dt;
end

function b = loadBuildings(cfg, truth)
baseDir = string(fileparts(mfilename('fullpath')));
if strlength(baseDir) == 0
    st = dbstack("-completenames");
    baseDir = string(fileparts(st(1).file));
end
searchDirs = [baseDir; fullfile(baseDir, "data"); string(pwd); fullfile(string(pwd), "data")];
fileNames = ["filtered_buiding_magok_b_box.txt"; "filtered_building_magok_b_box.txt"];
file = "";
for d = 1:numel(searchDirs)
    for n = 1:numel(fileNames)
        f = fullfile(searchDirs(d), fileNames(n));
        if exist(f, "file")
            file = f;
            break
        end
    end
    if file ~= "", break; end
    hit = dir(fullfile(searchDirs(d), "filtered*b*box*.txt"));
    if ~isempty(hit)
        file = fullfile(hit(1).folder, hit(1).name);
        break
    end
end
if file == ""
    error("Building txt file was not found. Put filtered_buiding_magok_b_box.txt in the same folder as this m-file.");
end
c = readcell(file);
raw = [cellfun(@num, c(:,2)), cellfun(@num, c(:,3)), cellfun(@num, c(:,4)), cellfun(@num, c(:,5)), cellfun(@num, c(:,6))];
xy = raw(:,1:2);
if mean(abs(xy(:,1))) > 50000, xy = xy - cfg.origin; end
r = hypot(raw(:,3), raw(:,4)) / 2;
z = raw(:,5);
pts = [truth(:,1:2); cfg.rx(:,1:2)];
m = 1500;
keep = xy(:,1) > min(pts(:,1))-m & xy(:,1) < max(pts(:,1))+m & xy(:,2) > min(pts(:,2))-m & xy(:,2) < max(pts(:,2))+m;
b.xy = xy(keep,:);
b.r = r(keep);
b.z = z(keep);
end

function y = num(x)
if isnumeric(x), y = x; else, y = str2double(string(x)); end
end

function [F, Q] = motion(cfg)
dt = cfg.dt;
F = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];
Q = cfg.sigmaA^2 * [dt^4/4 0 dt^3/2 0; 0 dt^4/4 0 dt^3/2; dt^3/2 0 dt^2 0; 0 dt^3/2 0 dt^2];
end

function [z, vis] = makeMeas(x, b, sc, cfg)
K = size(x,1);
S = size(cfg.rx,1);
idx = setdiff(1:S, cfg.ref);
z = zeros(K, S-1);
mask = false(K, S-1);
vis.los = zeros(K,1);
vis.nlos = zeros(K,1);
for k = 1:K
    p = [x(k,1:2), cfg.alt];
    blocked = false(S,1);
    rho = sqrt(sum((cfg.rx - p).^2, 2));
    noisy = zeros(S,1);
    for i = 1:S
        isNlos = rand < sc.p;
        if sc.kind == "building"
            isNlos = isNlos || ~isLos(p, cfg.rx(i,:), b);
        end
        if isNlos
            noise = cfg.sigmaNlos * randn;
            bias = cfg.biasMin + (cfg.biasMax - cfg.biasMin) * rand;
            blocked(i) = true;
        else
            noise = cfg.sigmaRange * randn;
            bias = 0;
        end
        noisy(i) = rho(i) + noise + bias;
    end
    pair = blocked(idx) | blocked(cfg.ref);
    z(k,:) = (noisy(idx) - noisy(cfg.ref))';
    mask(k,:) = pair';
    vis.los(k) = S - sum(blocked);
    vis.nlos(k) = sum(pair);
end
vis.ratio = mean(mask(:));
end

function ok = isLos(p, r, b)
if isempty(b.xy), ok = true; return; end
v = r - p;
vxy = v(1:2);
a = dot(vxy, vxy);
if a < 1e-12, ok = true; return; end
ok = true;
for i = 1:size(b.xy,1)
    dxy = p(1:2) - b.xy(i,:);
    bb = 2 * dot(dxy, vxy);
    c = dot(dxy, dxy) - b.r(i)^2;
    disc = bb^2 - 4 * a * c;
    if disc < 0, continue; end
    t0 = (-bb - sqrt(disc)) / (2 * a);
    t1 = (-bb + sqrt(disc)) / (2 * a);
    tin = max(0, min(t0, t1));
    tout = min(1, max(t0, t1));
    if tin > tout, continue; end
    zin = p(3) + tin * v(3);
    zout = p(3) + tout * v(3);
    if min(zin, zout) <= b.z(i) && max(zin, zout) >= 0
        ok = false;
        return
    end
end
end

function xhat = ekf(z, x0, P, F, Q, cfg)
K = size(z,1);
M = size(z,2);
x = x0;
xhat = zeros(K,4);
R0 = 2 * cfg.sigmaRange^2;
Rn = cfg.adaptiveRScale * R0;
I = eye(4);
for k = 1:K
    xp = F * x;
    Pp = F * P * F' + Q;
    h = htdoa(xp, cfg);
    H = jacobian(xp, cfg);
    r = z(k,:)' - h;
    R = R0 * eye(M);
    bad = abs(r) > cfg.gate;
    R(bad,bad) = Rn * eye(sum(bad));
    S = H * Pp * H' + R;
    G = Pp * H' / S;
    x = xp + G * r;
    P = (I-G*H) * Pp * (I-G*H)' + G * R * G';
    xhat(k,:) = x';
end
end

function xhat = pf(z, x0, P0, F, Q, cfg)
K = size(z,1);
N = cfg.Np;
L0 = chol(P0, "lower");
Lq = chol(Q + 1e-9*eye(4), "lower");
X = x0' + randn(N,4) * L0';
w = ones(N,1) / N;
xhat = zeros(K,4);
R0 = 2 * cfg.sigmaRange^2;
Rn = cfg.adaptiveRScale * R0;
for k = 1:K
    X = (F * X')' + randn(N,4) * Lq';
    H = hparticles(X, cfg);
    E = z(k,:) - H;
    V = R0 * ones(size(E));
    V(abs(E) > cfg.gate) = Rn;
    lw = log(w + realmin) - 0.5 * sum(E.^2 ./ V + log(2*pi*V), 2);
    lw = lw - max(lw);
    w = exp(lw) / sum(exp(lw));
    xhat(k,:) = sum(X .* w, 1);
    if 1 / sum(w.^2) < 0.5 * N
        id = resample(w);
        X = X(id,:) + randn(N,4) .* cfg.rough;
        w(:) = 1 / N;
    end
end
end

function h = htdoa(x, cfg)
rho = sqrt((x(1)-cfg.rx(:,1)).^2 + (x(2)-cfg.rx(:,2)).^2 + (cfg.alt-cfg.rx(:,3)).^2);
idx = setdiff(1:size(cfg.rx,1), cfg.ref);
h = rho(idx) - rho(cfg.ref);
end

function H = jacobian(x, cfg)
rho = sqrt((x(1)-cfg.rx(:,1)).^2 + (x(2)-cfg.rx(:,2)).^2 + (cfg.alt-cfg.rx(:,3)).^2);
D = [(x(1)-cfg.rx(:,1))./rho, (x(2)-cfg.rx(:,2))./rho];
idx = setdiff(1:size(cfg.rx,1), cfg.ref);
H = [D(idx,:) - D(cfg.ref,:), zeros(numel(idx),2)];
end

function H = hparticles(X, cfg)
S = size(cfg.rx,1);
N = size(X,1);
rho = zeros(N,S);
for i = 1:S
    rho(:,i) = sqrt((X(:,1)-cfg.rx(i,1)).^2 + (X(:,2)-cfg.rx(i,2)).^2 + (cfg.alt-cfg.rx(i,3)).^2);
end
idx = setdiff(1:S, cfg.ref);
H = rho(:,idx) - rho(:,cfg.ref);
end

function id = resample(w)
N = numel(w);
u = ((0:N-1)' + rand) / N;
c = cumsum(w);
id = zeros(N,1);
j = 1;
for i = 1:N
    while u(i) > c(j), j = j + 1; end
    id(i) = j;
end
end

function row = makeRow(sc, f, e, vis)
row = {char(sc.name), char(f), sc.alt, mean(e), sqrt(mean(e.^2)), percentileValue(e, 95), max(e), mean(vis.los), vis.ratio};
end

function y = percentileValue(x, pct)
x = sort(x(:));
r = 1 + (numel(x) - 1) * pct / 100;
lo = floor(r);
hi = ceil(r);
if lo == hi
    y = x(lo);
else
    y = x(lo) + (r - lo) * (x(hi) - x(lo));
end
end

function plotTrajectory(truth, xe, xp, b, sc, cfg)
name = char(sc.name);
figure("Color","w","Name",[name ' trajectory'],"NumberTitle","off");
hold on
if ~isempty(b.xy)
    step = max(1, ceil(size(b.xy,1) / 700));
    id = 1:step:size(b.xy,1);
    scatter(b.xy(id,1), b.xy(id,2), 10, [0.75 0.75 0.75])
end
h1 = plot(truth(:,1), truth(:,2), "k", "LineWidth", 2.6);
h2 = plot(xe(:,1), xe(:,2), "b--", "LineWidth", 1.6);
h3 = plot(xp(:,1), xp(:,2), "r-.", "LineWidth", 1.5);
h4 = scatter(cfg.rx(:,1), cfg.rx(:,2), 70, [0.00 0.45 0.10], "filled");
axis equal; grid on; box on
xlabel("x position [m]"); ylabel("y position [m]")
title(sprintf("%s trajectory (tdoa, altitude %d m)", name, sc.alt), "Interpreter","none")
legend([h1 h2 h3 h4], "Truth", "EKF", "PF", "Stations", "Location","northeast")
set(gca, "FontSize", 12)
end

function plotError(t, r)
name = char(r.sc.name);
figure("Color","w","Name",[name ' error'],"NumberTitle","off");
yyaxis left
h1 = plot(t, r.ee, "b", "LineWidth", 1.2); hold on
h2 = plot(t, r.ep, "Color", [1 0 0], "LineStyle", "-", "LineWidth", 1.2);
ylabel("position error [m]")
ylim([0, niceLimit(max([r.ee(:); r.ep(:); 1]))])
ax = gca;
ax.YAxis(1).Color = [0 0.4470 0.7410];
yyaxis right
h3 = stairs(t, r.vis.nlos, "k:", "LineWidth", 0.8);
ylabel("NLOS measurement count")
if max(r.vis.nlos) == 0
    ylim([0 1])
else
    ylim([0 10])
end
ax = gca;
ax.YAxis(2).Color = [0.8500 0.3250 0.0980];
grid on; box on
xlim([0 250])
xlabel("time [s]")
title(sprintf("%s position error", name), "Interpreter","none")
legend([h1 h2 h3], "EKF error", "PF error", "NLOS count", "Location","northeast")
set(gca, "FontSize", 12)
end

function lim = niceLimit(v)
lim = 10 * ceil(1.05 * v / 10);
lim = max(50, min(100, lim));
end
