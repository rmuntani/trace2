#include "ruby.h"

struct classes_list {
  struct classes_list *next;
  struct classes_stack *curr;
} classes_list;

struct classes_stack {
  const char* name;
  const char* method;
  int lineno;
  const char* path;
  struct classes_stack *prev;
  struct classes_list *callees;
} classes_stack;

struct classes_stack *top;
struct classes_list *list_head;
struct classes_list *list_tail;

VALUE event_processor;

void pop_stack_to_list();
void insert_callee(struct classes_stack*, struct classes_stack*);
void push_to_stack(rb_trace_arg_t*);
void update_classes_stack(VALUE);
void process_event(VALUE, VALUE) ;
void aggregate_uses(VALUE);
