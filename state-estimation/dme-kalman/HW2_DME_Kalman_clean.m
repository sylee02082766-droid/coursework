%% HW#2 DME Kalman Filter Solution Script
% This script solves:
% 1) True/nominal simulation
% 2) Linearized Kalman Filter (LKF)
% 3) Extended Kalman Filter (EKF)
% 4) LKF vs EKF comparison
% 5) Same procedure for a right-turn circular trajectory
%
% NOTE: The problem statement image/PDF does not show numerical values for
%       sigma_1, sigma_2. Here sigma_1 = sigma_2 = 30 m is used only as an
%       example. Replace sigR1, sigR2 if your instructor gave other values.

clear; clc; close all;
rng(7);                         % random seed for repeatability

%% Common parameters
dt = 1;                         % sec
Tend = 300;                     % sec
t = 0:dt:Tend;
Ns = length(t);

V = 684000/3600;                % 684 km/h = 190 m/s
course = deg2rad(30);           % north-referenced course angle for straight case
vN0 = V*cos(course);
vE0 = V*sin(course);

station = [53000, 19000;        % DME station #1: [N, E] m
           32000, 38000];       % DME station #2: [N, E] m

sigR1 = 30;                     % DME #1 measurement std [m]
sigR2 = 30;                     % DME #2 measurement std [m]
R = diag([sigR1^2, sigR2^2]);

sigN = 1;                       % process-noise acceleration std in N axis
sigE = 1;                       % process-noise acceleration std in E axis

F = [1 0 dt 0;
     0 1 0 dt;
     0 0 1 0;
     0 0 0 1];
G = [0.5*dt^2 0;
     0 0.5*dt^2;
     dt 0;
     0 dt];
Q = G*diag([sigN^2, sigE^2])*G.';

P0 = diag([500^2, 500^2, 10^2, 10^2]);

%% ================================================================
%% 1) Straight-flight true/nominal simulation
%% ================================================================
xTrueS = zeros(4,Ns);
xTrueS(1,:) = vN0*t;
xTrueS(2,:) = vE0*t;
xTrueS(3,:) = vN0;
xTrueS(4,:) = vE0;

zTrueS = zeros(2,Ns);
for k = 1:Ns
    zTrueS(:,k) = hDME(xTrueS(:,k), station);
end
zS = zTrueS + [sigR1; sigR2].*randn(2,Ns);

figure('Name','P1 Straight trajectory');
plot(xTrueS(2,:), xTrueS(1,:), 'LineWidth', 1.5); hold on;
plot(station(:,2), station(:,1), '^', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(xTrueS(2,1), xTrueS(1,1), 'o', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(xTrueS(2,end), xTrueS(1,end), 'x', 'MarkerSize', 8, 'LineWidth', 1.5);
grid on; axis equal;
xlabel('East E [m]'); ylabel('North N [m]');
title('Problem 1: straight nominal trajectory and DME stations');
legend('Nominal / true trajectory','DME stations','Start','End','Location','best');

figure('Name','P1 Straight measurements');
plot(t, zS(1,:), 'LineWidth', 1.0); hold on;
plot(t, zTrueS(1,:), '--', 'LineWidth', 1.0);
plot(t, zS(2,:), 'LineWidth', 1.0);
plot(t, zTrueS(2,:), '--', 'LineWidth', 1.0);
grid on;
xlabel('Time [s]'); ylabel('Range [m]');
title('Problem 1: DME measurements z_1, z_2');
legend('z_1 noisy','z_1 true range','z_2 noisy','z_2 true range','Location','best');

%% ================================================================
%% 2) Linearized Kalman Filter: straight flight
%% ================================================================
xhat0S = [200; -150; vN0; vE0];
[xLKF_S, P_LKF_S] = runLKF(zS, xTrueS, xhat0S, P0, F, Q, R, station);

plotStateWithTwoSigma(t, xTrueS, xLKF_S, P_LKF_S, 'Problem 2: straight LKF states');
plotNE(xTrueS, xLKF_S, station, 'Problem 2: straight LKF N-E comparison', 'LKF estimate');

%% ================================================================
%% 3) Extended Kalman Filter: straight flight
%% ================================================================
[xEKF_S, P_EKF_S] = runEKF(zS, xhat0S, P0, F, Q, R, station);

plotStateWithTwoSigma(t, xTrueS, xEKF_S, P_EKF_S, 'Problem 3: straight EKF states');
plotNE(xTrueS, xEKF_S, station, 'Problem 3: straight EKF N-E comparison', 'EKF estimate');

%% ================================================================
%% 4) Straight-flight comparison
%% ================================================================
plotLKFEKFCompare(t, xTrueS, xLKF_S, xEKF_S, 'Problem 4: straight LKF vs EKF');
printRMSE('Straight', xTrueS, xLKF_S, xEKF_S);

%% ================================================================
%% 5) Circular right-turn case: repeat 1)~4)
%% ================================================================
% Assumption for circular case:
% Center is (cN,cE)=(0,45000) m and radius is 45000 m.
% Because the initial position (0,0) lies south of the center, right turn
% means the initial heading is northbound. Thus v(0)=[190,0] m/s.
Rc = 45000;
cN = 0;
cE = 45000;
omega = V/Rc;
theta = -pi/2 + omega*t;

xTrueC = zeros(4,Ns);
xTrueC(1,:) = cN + Rc*cos(theta);
xTrueC(2,:) = cE + Rc*sin(theta);
xTrueC(3,:) = -Rc*omega*sin(theta);
xTrueC(4,:) =  Rc*omega*cos(theta);

zTrueC = zeros(2,Ns);
for k = 1:Ns
    zTrueC(:,k) = hDME(xTrueC(:,k), station);
end
zC = zTrueC + [sigR1; sigR2].*randn(2,Ns);

figure('Name','P5 Circular trajectory');
plot(xTrueC(2,:), xTrueC(1,:), 'LineWidth', 1.5); hold on;
plot(station(:,2), station(:,1), '^', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(xTrueC(2,1), xTrueC(1,1), 'o', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(xTrueC(2,end), xTrueC(1,end), 'x', 'MarkerSize', 8, 'LineWidth', 1.5);
grid on; axis equal;
xlabel('East E [m]'); ylabel('North N [m]');
title('Problem 5: circular nominal trajectory and DME stations');
legend('Nominal / true trajectory','DME stations','Start','End','Location','best');

figure('Name','P5 Circular measurements');
plot(t, zC(1,:), 'LineWidth', 1.0); hold on;
plot(t, zTrueC(1,:), '--', 'LineWidth', 1.0);
plot(t, zC(2,:), 'LineWidth', 1.0);
plot(t, zTrueC(2,:), '--', 'LineWidth', 1.0);
grid on;
xlabel('Time [s]'); ylabel('Range [m]');
title('Problem 5: circular DME measurements z_1, z_2');
legend('z_1 noisy','z_1 true range','z_2 noisy','z_2 true range','Location','best');

xhat0C = [200; -150; xTrueC(3,1); xTrueC(4,1)];
[xLKF_C, P_LKF_C] = runLKF(zC, xTrueC, xhat0C, P0, F, Q, R, station);
[xEKF_C, P_EKF_C] = runEKF(zC, xhat0C, P0, F, Q, R, station);

plotStateWithTwoSigma(t, xTrueC, xLKF_C, P_LKF_C, 'Problem 5: circular LKF states');
plotNE(xTrueC, xLKF_C, station, 'Problem 5: circular LKF N-E comparison', 'LKF estimate');

plotStateWithTwoSigma(t, xTrueC, xEKF_C, P_EKF_C, 'Problem 5: circular EKF states');
plotNE(xTrueC, xEKF_C, station, 'Problem 5: circular EKF N-E comparison', 'EKF estimate');

plotLKFEKFCompare(t, xTrueC, xLKF_C, xEKF_C, 'Problem 5: circular LKF vs EKF');
printRMSE('Circular', xTrueC, xLKF_C, xEKF_C);

%% ========================= Local functions =========================
function z = hDME(x, station)
    pN = x(1); pE = x(2);
    z = zeros(2,1);
    for i = 1:2
        dN = pN - station(i,1);
        dE = pE - station(i,2);
        z(i) = sqrt(dN^2 + dE^2);
    end
end

function H = HjacDME(x, station)
    pN = x(1); pE = x(2);
    H = zeros(2,4);
    for i = 1:2
        dN = pN - station(i,1);
        dE = pE - station(i,2);
        r = sqrt(dN^2 + dE^2);
        H(i,1) = dN/r;
        H(i,2) = dE/r;
        H(i,3) = 0;
        H(i,4) = 0;
    end
end

function [xhat, Pstore] = runLKF(z, xref, xhat0, P0, F, Q, R, station)
    Ns = size(z,2);
    xhat = zeros(4,Ns);
    Pstore = zeros(4,4,Ns);
    xprev = xhat0;
    Pprev = P0;
    I = eye(4);
    for k = 1:Ns
        if k == 1
            xpred = xprev;
            Ppred = Pprev;
        else
            xpred = F*xprev;
            Ppred = F*Pprev*F.' + Q;
        end
        H = HjacDME(xref(:,k), station);
        innov = z(:,k) - hDME(xref(:,k), station) - H*(xpred - xref(:,k));
        S = H*Ppred*H.' + R;
        K = Ppred*H.'/S;
        xnew = xpred + K*innov;
        Pnew = (I-K*H)*Ppred*(I-K*H).' + K*R*K.';  % Joseph form
        xhat(:,k) = xnew;
        Pstore(:,:,k) = Pnew;
        xprev = xnew;
        Pprev = Pnew;
    end
end

function [xhat, Pstore] = runEKF(z, xhat0, P0, F, Q, R, station)
    Ns = size(z,2);
    xhat = zeros(4,Ns);
    Pstore = zeros(4,4,Ns);
    xprev = xhat0;
    Pprev = P0;
    I = eye(4);
    for k = 1:Ns
        if k == 1
            xpred = xprev;
            Ppred = Pprev;
        else
            xpred = F*xprev;
            Ppred = F*Pprev*F.' + Q;
        end
        H = HjacDME(xpred, station);
        innov = z(:,k) - hDME(xpred, station);
        S = H*Ppred*H.' + R;
        K = Ppred*H.'/S;
        xnew = xpred + K*innov;
        Pnew = (I-K*H)*Ppred*(I-K*H).' + K*R*K.';  % Joseph form
        xhat(:,k) = xnew;
        Pstore(:,:,k) = Pnew;
        xprev = xnew;
        Pprev = Pnew;
    end
end

function plotStateWithTwoSigma(t, xTrue, xhat, P, figTitle)
    ylabels = {'p_N [m]','p_E [m]','v_N [m/s]','v_E [m/s]'};
    figure('Name',figTitle);
    for i = 1:4
        subplot(2,2,i);
        sig2 = 2*sqrt(squeeze(P(i,i,:))).';
        plot(t, xTrue(i,:), 'LineWidth', 1.2); hold on;
        plot(t, xhat(i,:), 'LineWidth', 1.2);
        plot(t, xhat(i,:) + sig2, '--', 'LineWidth', 0.8);
        plot(t, xhat(i,:) - sig2, '--', 'LineWidth', 0.8);
        grid on;
        xlabel('Time [s]'); ylabel(ylabels{i});
        title(ylabels{i});
        if i == 1
            legend('True','Estimate','+2sigma','-2sigma','Location','best');
        end
    end
    sgtitle(figTitle);
end

function plotNE(xTrue, xhat, station, figTitle, estLabel)
    figure('Name',figTitle);
    plot(xTrue(2,:), xTrue(1,:), 'LineWidth', 1.5); hold on;
    plot(xhat(2,:), xhat(1,:), 'LineWidth', 1.2);
    plot(station(:,2), station(:,1), '^', 'MarkerSize', 8, 'LineWidth', 1.5);
    grid on; axis equal;
    xlabel('East E [m]'); ylabel('North N [m]');
    title(figTitle);
    legend('True', estLabel, 'DME stations','Location','best');
end

function plotLKFEKFCompare(t, xTrue, xLKF, xEKF, figTitle)
    ylabels = {'p_N [m]','p_E [m]','v_N [m/s]','v_E [m/s]'};
    figure('Name',figTitle);
    for i = 1:4
        subplot(2,2,i);
        plot(t, xTrue(i,:), 'LineWidth', 1.2); hold on;
        plot(t, xLKF(i,:), 'LineWidth', 1.0);
        plot(t, xEKF(i,:), 'LineWidth', 1.0);
        grid on;
        xlabel('Time [s]'); ylabel(ylabels{i});
        title(ylabels{i});
        if i == 1
            legend('True','LKF','EKF','Location','best');
        end
    end
    sgtitle(figTitle);
end

function printRMSE(name, xTrue, xLKF, xEKF)
    eposLKF = sqrt(sum((xLKF(1:2,:) - xTrue(1:2,:)).^2,1));
    eposEKF = sqrt(sum((xEKF(1:2,:) - xTrue(1:2,:)).^2,1));
    evelLKF = sqrt(sum((xLKF(3:4,:) - xTrue(3:4,:)).^2,1));
    evelEKF = sqrt(sum((xEKF(3:4,:) - xTrue(3:4,:)).^2,1));
    fprintf('\n[%s]\n', name);
    fprintf('Position RMSE: LKF = %.3f m, EKF = %.3f m\n', rms(eposLKF), rms(eposEKF));
    fprintf('Velocity RMSE: LKF = %.3f m/s, EKF = %.3f m/s\n', rms(evelLKF), rms(evelEKF));
end
