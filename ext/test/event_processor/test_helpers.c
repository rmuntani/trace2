#include <stdlib.h>
#include "../event_processor.h"

void clear_stack() {
  classes_stack *free_top;

  while (top) {
    free_top = top;
    top = top->prev;
    free(free_top);
  }
}
