# DME Kalman-filter coursework

MATLAB coursework by LEE SANGYEOP comparing a linearized Kalman filter (LKF) with an extended Kalman filter (EKF) using two simulated distance-measuring equipment (DME) stations. The original script is preserved without behavioral changes.

The demonstration generates a straight flight and a circular right turn, adds synthetic range-measurement noise, estimates North/East position and velocity, and plots trajectories and state estimates with ±2σ bounds. It prints position and velocity RMSE for both methods.

## Run

Open this directory in MATLAB and run:

```matlab
HW2_DME_Kalman_clean
```

The script is self-contained and reads no external data. MATLAB R2024b is the available local installation; other versions have not been checked. It uses script-local functions, `sgtitle`, and `rms`. Running it clears the current workspace and closes existing figures.

A numerical smoke run completed in MATLAB R2024b with finite estimates and exit status 0. See [VALIDATION.md](VALIDATION.md) for the synthetic example results and verification bounds.

## Modeling assumptions

- Both DME measurement standard deviations are **30 m**, an illustrative assumption because the original exercise image did not supply those values.
- Speed is **190 m/s**, the sampling interval is **1 s**, and each trajectory lasts **300 s**.
- The circular trajectory has a **45 km** radius; both cases use a constant-velocity filter model with process noise.
- `rng(7)` makes the synthetic measurements repeatable.
- The LKF linearizes around the supplied reference trajectory, which is the simulated true trajectory in this exercise. The EKF linearizes around the predicted estimate. This is an educational comparison, not a benchmark with an independently imperfect flight-plan reference.

This code uses fabricated trajectories and station coordinates. It is not real flight data or an operational DME navigation implementation. No homework statement, lecture document, or submitted report is distributed.

한글 요약: 직접 작성한 수업용 DME 항법 추정 코드입니다. 직선·원운동의 합성 거리 관측으로 LKF와 EKF를 비교하며, DME 잡음 표준편차 30 m는 예제용 가정입니다. 원본 코드와 결과 해석의 범위를 함께 보존했습니다.
