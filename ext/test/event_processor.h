#include "ruby.h"

struct classes_list;

typedef struct class_use {
  const char* name;
  const char* method;
  int lineno;
  const char* path;
  struct class_use* caller;
  struct classes_list* callee;
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

struct classes_list *list_head;
struct classes_list *list_tail;

VALUE event_processor;

class_use *pop(classes_stack**);
void *insert(classes_list **head, classes_list **tail, class_use *top);
void pop_stack_to_list();
void insert_callee(struct classes_stack*, struct classes_stack*);
void push_to_stack(rb_trace_arg_t*);
void update_classes_stack(VALUE);
void process_event(VALUE, VALUE) ;
void aggregate_uses(VALUE);
