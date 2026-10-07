# Coursework in C and MATLAB

Coursework from Korea Aerospace University, maintained as a record of learning by LEE SANGYEOP. The C examples cover array traversal, dynamic memory, linked lists, and a stack with constant-time maximum lookup. The MATLAB examples compare DME LKF/EKF estimation and UAM MLAT/TDOA EKF/Particle Filter estimation.

## Examples

| Folder | Implementation | Input and output |
| --- | --- | --- |
| `data-structures/arrays` | Maximum value over a range of rows in a two-dimensional array | `N M`, the array, query count, then zero-based inclusive row ranges. Prints one maximum per query. |
| `data-structures/linked-list` | Store integers in input order and print even values | Integer count followed by values. Prints even values, including negative numbers, zero, and duplicates. |
| `data-structures/max-stack` | Linked stack whose nodes cache the maximum of the remaining stack | Command count, then `1 x` to push, `2` to pop, or `3` to print the maximum. Empty maximum returns `-1`. |
| `state-estimation/dme-kalman` | MATLAB DME LKF/EKF comparison for straight and circular flight | Synthetic trajectories and range observations; plots state estimates and prints position/velocity RMSE. |
| `state-estimation/uam-ekf-pf` | Probabilistic Sensor Engineering term project: UAM EKF/Particle Filter comparison | Five LOS/NLOS scenarios with eleven virtual receivers; uses fabricated demo buildings and prints error metrics. |

The array example assumes `1 <= N, M <= 100` and valid row ranges. All examples assume well-formed input; they are learning exercises rather than hardened input parsers. The stack uses `-1` for an empty stack, so an empty result and an actual maximum of `-1` cannot be distinguished by output alone. Initialization allocation failures are not handled in that example.

## Build and run

Each C source is a separate console program using only the C standard library. A C99-or-later compiler is required. For GCC, run these commands from the repository root:

```sh
mkdir -p build
gcc -std=c11 -Wall -Wextra -pedantic data-structures/arrays/week03_array.c -o build/array
gcc -std=c11 -Wall -Wextra -pedantic data-structures/linked-list/week04_list.c -o build/list
gcc -std=c11 -Wall -Wextra -pedantic data-structures/max-stack/week05_stack.c -o build/stack

./build/array < data-structures/arrays/tests/test1.in
./build/list < data-structures/linked-list/tests/test1.in
./build/stack < data-structures/max-stack/tests/negative_values.in
```

On Windows, create `build` with `New-Item -ItemType Directory -Force build`, add `.exe` to each output name, and supply input from PowerShell, for example:

```powershell
Get-Content -Raw .\data-structures\max-stack\tests\negative_values.in | .\build\stack.exe
```

Test inputs and expected outputs are next to each program. Compare numeric output while allowing newline differences; the list program intentionally writes a trailing space. They cover negative values, repeated maxima, empty stacks, and order preservation.

For the MATLAB example, open `state-estimation/dme-kalman` in MATLAB and run `HW2_DME_Kalman_clean`. See its [local README](state-estimation/dme-kalman/README.md) for assumptions, requirements, and interpretation. In particular, the 30 m DME noise level is illustrative, and the LKF reference is the simulated true trajectory.

For the UAM coursework example, open `state-estimation/uam-ekf-pf` and run `uam_tdoa_ekf_pf`. Its [local README](state-estimation/uam-ekf-pf/README.md) distinguishes the unchanged source from the fabricated public obstacle data and the original submitted coursework results.

## Provenance and verification

These implementations follow coursework exercises and hints. See [ATTRIBUTION.md](ATTRIBUTION.md) for scope. Lecture slides, assignment statements, provided sample files, exam material, submitted reports, and personal student identifiers are excluded.

The three packaged C sources are unchanged copies of the reviewed local implementations. Their SHA-256 hashes match existing local verification records covering 5 array, 8 list, and 5 stack cases. [verification.json](verification.json) records those matches. No fresh C compilation or execution was performed for this packaging step. The original MATLAB script was added after its author confirmed ownership and public-sharing permission; it is also copied without behavioral changes. A MATLAB R2024b numerical smoke run completed with finite estimates and exit status 0; [its validation record](state-estimation/dme-kalman/VALIDATION.md) labels the results as synthetic.

## 한국어 안내

한국항공대학교 수업에서 학습한 C·MATLAB 코드 모음입니다. 배열의 구간 최댓값, 연결 리스트의 짝수 출력, 최댓값을 저장하는 연결 스택, DME 기반 LKF/EKF 비교와 확률론적센서공학의 UAM EKF/PF 최종 프로젝트를 정리했습니다. 강의자료·문제지·시험자료·제출 보고서 대신 구현 코드와 직접 설계한 입력/예상 출력만 포함했습니다. 원본 코드를 유지했으며 입력 형식과 모델 가정은 위 설명과 각 폴더의 안내를 참고하세요.
