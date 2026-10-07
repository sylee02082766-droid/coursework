# Coursework context

These files are learning implementations prepared for coursework at Korea Aerospace University. The Data Structures and Lab exercises specify the data structures, interfaces, and expected behavior, and those solutions follow course hints. The MATLAB DME script was confirmed by LEE SANGYEOP as his own coursework, with permission to share publicly. These files are not presented as new algorithms or as the authoring of the course materials.

| Source | Context |
| --- | --- |
| `week03_array.c` | Row-range maximum exercise; the `findMax` interface and the array column bound follow the course hint. |
| `week04_list.c` | Linked-list exercise; `node`, `insert`, and `print_even` follow the specified interfaces. The implementation preserves input order and frees the list. |
| `week05_stack.c` | User-provided classroom implementation, cleaned for submission by removing an unused global pointer, removing trailing whitespace from `scanf` formats, and removing a redundant `get_max` call. The stack scaffold follows course material; cached maximum state follows the exercise requirement. |
| `state-estimation/dme-kalman/HW2_DME_Kalman_clean.m` | Original user-authored DME LKF/EKF homework simulation, preserved unchanged. The exercise's unspecified DME noise is filled with an explicit illustrative 30 m assumption. |
| `state-estimation/uam-ekf-pf/uam_tdoa_ekf_pf.m` | Original desktop implementation associated with the user's Probabilistic Sensor Engineering term-project report. Source is preserved unchanged; public inputs use fabricated obstacles instead of the original GIS records. |

No lecture documents, starter-file copies, assignment problem text, provided sample test files, or third-party dependencies are distributed here. No open-source license has been selected for this collection.
