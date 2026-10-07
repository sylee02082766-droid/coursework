# Public-input smoke check

The unchanged coursework script was executed once in MATLAB R2024b on 2026-10-07 using the four fabricated public obstacles. All ten filter/scenario combinations had finite estimates and error metrics. MATLAB exited with status 0.

| Scenario | EKF RMSE [m] | PF RMSE [m] | EKF P95 [m] | PF P95 [m] |
| --- | ---: | ---: | ---: | ---: |
| LOS, 450 m | 8.9900 | 9.8131 | 18.355 | 20.376 |
| Random NLOS, 450 m | 14.450 | 16.205 | 30.506 | 35.501 |
| Building NLOS, 300 m | 11.199 | 10.158 | 23.549 | 21.545 |
| Building NLOS, 450 m | 11.703 | 10.324 | 24.286 | 20.542 |
| Building NLOS, 600 m | 8.4308 | 9.1703 | 14.775 | 18.616 |

These are the printed metrics of one seeded educational simulation. They do not reproduce the submitted coursework's building-data results or establish real-world performance or a general ranking of EKF versus PF. Original GIS records were not used. Figures were hidden; plot appearance and other MATLAB versions were not checked. No Monte Carlo run was performed.

Original source SHA-256: `6b576c99172c38f20b4a9255555a09f86e4c5c28c74d8efa8646429ec12d4080`.

Fabricated obstacle-file SHA-256: `d47795a60b0f6e63e8f4d34710291ca476dfe9ac269831e7086f2f42d957d21c`.
