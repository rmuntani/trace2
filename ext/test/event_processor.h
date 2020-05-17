#include "ruby.h"

typedef struct class_use {
  char* name;
  char* method;
  char* path;
  int lineno;
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
void insert(classes_list**, classes_list**, class_use*);
void add_callee_to_caller(class_use**, class_use**);
void push(classes_stack**, class_use*);
void pop_stack_to_list(classes_stack**, classes_list**, classes_list**);
void push_new_class_use(rb_trace_arg_t*, classes_stack**);
void clear_stack(classes_stack **top);
void clear_list(classes_list **head, classes_list **tail);
