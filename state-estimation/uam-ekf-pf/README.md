# UAM MLAT/TDOA coursework — EKF and Particle Filter

Probabilistic Sensor Engineering term-project implementation by LEE SANGYEOP. This is the original MATLAB source found on the desktop and associated with the coursework presentation titled *MLAT/TDOA-based EKF/PF Comparison for UAM Position Estimation*.

This example is separate from the later three-dimensional UAM tracking research with flight-plan priors. It estimates a two-dimensional state `[px, py, vx, vy]` using eleven virtual MLAT receivers, noisy range differences, and either an EKF or a 1,500-particle filter.

## Run

Open this directory in MATLAB and run:

```matlab
uam_tdoa_ekf_pf
```

The script prints mean error, RMSE, P95, maximum error, mean LOS count, and NLOS ratio. It plots the LOS trajectory and error traces for five scenarios: LOS, random NLOS, and building-related NLOS at 300 m, 450 m, and 600 m altitude. It clears the current workspace and closes existing figures. MATLAB R2024b is the available local installation; other versions have not been checked. The script defines its own percentile calculation and uses MATLAB's table, file-import, and plotting functions.

A single seeded smoke execution completed with finite estimates and exit status 0; [VALIDATION.md](VALIDATION.md) records the public synthetic-input results and their limits.

## Public demonstration data

`filtered_buiding_magok_b_box.txt` contains **four fabricated obstacles**, reused from the public synthetic demonstration in the related UAM research repository. The legacy misspelled filename is retained because the original importer recognizes it. Columns are an illustrative ID, X [m], Y [m], width [m], depth [m], and height [m]. There is no header. The records do not describe actual buildings or a real radio deployment.

The original desktop GIS file is excluded because its upstream provenance and redistribution terms were not established. The algorithm source is unchanged; only its accompanying public input is synthetic. Therefore, output from this package is **not the original term-project result**, nor a reproduction of the submitted presentation's numbers.

## Assumptions and limits

- Constant-velocity motion model and a 1 s interval; altitude is fixed within each scenario rather than estimated.
- LOS range noise standard deviation 6 m; NLOS noise 20 m with a 25–90 m positive bias.
- TDOA differences share a reference receiver, but the filters simplify the measurement covariance as diagonal.
- Receiver geometry, cylindrical building approximations, residual-based noise inflation, and PF roughening are educational model choices.
- EKF and PF use the same observations within each scenario. This script performs one seeded realization per scenario, not a Monte Carlo comparison or a general ranking of the filters.
- Plot limits are fixed by the original implementation and may clip unusually large errors.

No industrial source, raw GIS records, real flight data, lecture material, or personal identifiers are included. No new source license has been assigned.

한글 요약: 확률론적센서공학 최종 프로젝트의 2차원 UAM 위치추정 코드입니다. 같은 TDOA 관측에 EKF와 PF를 적용해 LOS/NLOS 조건을 비교합니다. 원본 알고리즘은 유지하고 공개용 입력에는 직접 만든 합성 장애물만 넣었으므로, 실행 결과는 기존 제출 보고서 수치와 구분해야 합니다.
