#include <stdio.h>
#include <stdlib.h>

typedef struct node {
    int key;
    struct node *next;
} node;

node *insert(int k, node *t) {
    node *s;
    s = (node *)malloc(sizeof(node));
    if (s == NULL) {
        return s;
    }
    s->key = k;
    s->next = t->next;
    t->next = s;
    return s;
}

void print_even(node *head) {
    node *p = head->next;

    while (p != NULL) {
        if (p->key % 2 == 0) {
            printf("%d ", p->key);
        }
        p = p->next;
    }
    printf("\n");
}

int main(void) {
    int N, k;
    node *head = (node *)malloc(sizeof(node));
    if (head == NULL) {
        return 1;
    }
    head->next = NULL;
    node *last = head;

    scanf("%d", &N);
    for (int i = 0; i < N; i++) {
        scanf("%d", &k);
        last = insert(k, last);
        if (last == NULL) {
            return 1;
        }
    }

    print_even(head);

    node *s, *t;
    t = head;
    while (t != NULL) {
        s = t;
        t = t->next;
        free(s);
    }
    return 0;
}
