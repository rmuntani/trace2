#include <stdlib.h>
#include "../event_processor.h"

extern struct classes_stack *top;
extern struct classes_list *list_head;
extern struct classes_list *list_tail;

void clear_stack() {
  classes_stack *free_top;

  while (top) {
    free_top = top;
    top = top->prev;
    free(free_top);
  }
}

void clear_list() {
  struct classes_list *free_node;

  while(list_head) {
    free_node = list_head;
    list_head = list_head->next;
    free(free_node);
  }
  free(list_tail);
}
