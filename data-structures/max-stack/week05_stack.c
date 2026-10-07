#include <stdio.h>
#include <stdlib.h>

typedef struct _node {
    int key;
    int max;
    struct _node *next;
} node;

node *head, *tail;

void init_stack(void) {
    head = (node *)malloc(sizeof(node));
    tail = (node *)malloc(sizeof(node));

    head->next = tail;
    tail->next = NULL;
}

int push(int k) {
    node *t;
    if ((t = (node *)malloc(sizeof(node))) == NULL)
        return -1;
    t->key = k;
    if (head->next == tail) {
        t->max = k;
    } else if (k > head->next->max) {
        t->max = k;
    } else {
        t->max = head->next->max;
    }
    t->next = head->next;
    head->next = t;
    return k;
}

int pop(void) {
    node *t;
    int i;
    if (head->next == tail) {
        return -1;
    }
    t = head->next;
    i = t->key;
    head->next = t->next;
    free(t);

    return i;
}

int get_max(void) {
    if (head->next == tail)
        return -1;

    return head->next->max;
}

void clean_stack(void) {
    node *t, *s;

    t = head->next;

    while (t != tail) {
        s = t;
        t = t->next;
        free(s);
    }

    head->next = tail;
}

int main(void) {
    int N;
    int command, x;

    init_stack();

    scanf("%d", &N);

    for (int i = 0; i < N; i++) {
        scanf("%d", &command);

        if (command == 1) {
            scanf("%d", &x);
            push(x);
        }
        else if (command == 2) {
            pop();
        }
        else if (command == 3) {
            printf("%d\n", get_max());
        }
    }

    clean_stack();

    free(head);
    free(tail);

    return 0;
}
