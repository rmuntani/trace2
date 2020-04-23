#include "ruby.h"

struct classes_list;

typedef struct class_use {
  const char* name;
  const char* method;
  int lineno;
  const char* path;
  struct class_use* caller;
  struct classes_list* head_callee;
  struct classes_list* tail_callee;
} class_use;

typedef struct classes_list {
  struct classes_list *next;
  class_use *class_use;
} classes_list;

typedef struct classes_stack {
  struct classes_stack *prev;
  class_use *class_use;
} classes_stack;

classes_list *list_head;
classes_list *list_tail;
classes_stack *top;

VALUE event_processor;

class_use *pop(classes_stack**);
void insert(classes_list **head, classes_list **tail, class_use *top);
void add_callee_to_caller(class_use **callee, class_use **caller);
void push(classes_stack **top, class_use *new_use);
