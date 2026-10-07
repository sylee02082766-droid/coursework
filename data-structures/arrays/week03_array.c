#include <stdio.h>

int findMax(int arr[][100], int M, int r1, int r2) {
    int max = arr[r1][0];

    for (int i = r1; i <= r2; i++) {
        for (int j = 0; j < M; j++) {
            if (arr[i][j] > max) {
                max = arr[i][j];
            }
        }
    }

    return max;
}

int main(void) {
    int N, M;
    int arr[100][100];

    scanf("%d %d", &N, &M);

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            scanf("%d", &arr[i][j]);
        }
    }

    int K;
    scanf("%d", &K);

    for (int i = 0; i < K; i++) {
        int r1, r2;
        scanf("%d %d", &r1, &r2);
        printf("%d\n", findMax(arr, M, r1, r2));
    }

    return 0;
}
