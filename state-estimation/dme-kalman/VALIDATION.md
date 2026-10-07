# MATLAB smoke check

Executed on 2026-10-07 with MATLAB R2024b. The original script completed, all straight/circular LKF and EKF state estimates passed a finite-value check, and MATLAB exited with status 0.

| Scenario | LKF position RMSE [m] | EKF position RMSE [m] | LKF velocity RMSE [m/s] | EKF velocity RMSE [m/s] |
| --- | ---: | ---: | ---: | ---: |
| Straight | 23.632 | 23.588 | 2.238 | 2.238 |
| Circular | 46.016 | 45.991 | 7.618 | 7.617 |

These are the script's printed values for `rng(7)`, illustrative 30 m DME noise, and its synthetic trajectories. They confirm that this example executes; they do not establish real-world navigation accuracy or general superiority of one filter.

Source SHA-256: `48ed7fdb42b360e7a6a569cff789379e351f506fc09aa31ce99181f76e194fbd`.

The smoke wrapper hid figures and checked finite estimates without modifying the source or reproducing its mathematical implementation as a test. Full plotting appearance and other MATLAB versions were not reviewed.
