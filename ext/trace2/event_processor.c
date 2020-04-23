#include <stdlib.h>
#include "ruby.h"
#include "ruby/ruby.h"
#include "ruby/debug.h"
#include "name_finder.h"
// TODO: remove this eventually
#include "munit/munit.h"

struct classes_list;

typedef struct class_use {
  const char* name;
  const char* method;
  const char* path;
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

class_use *pop(classes_stack **top) {
  if (*top == NULL) {
    return NULL;
  }
  else {
    class_use *popped_value = (*top)->class_use;

    *top = (*top)->prev;

    return popped_value;
  }
}

void insert(classes_list **head, classes_list **tail, class_use *class_use) {
  classes_list *new_node = malloc(sizeof(classes_list));
  new_node->class_use = class_use;
  new_node->next = NULL;

  if (*head == NULL) {
    *head = new_node;
  } else if (*tail == NULL) {
    (*head)->next = new_node;
    *tail = new_node;
  } else {
    (*tail)->next = new_node;
    *tail = (*tail)->next;
  }
}

void push(classes_stack **top, class_use *new_use) {
  classes_stack *new_top = malloc(sizeof(classes_stack));

  new_top->prev = *top;
  new_top->class_use = new_use;

  *top = new_top;
}

void add_callee_to_caller(class_use **callee, class_use **caller) {
  (*callee)->caller = *caller;
  insert(&(*caller)->head_callee, &(*caller)->tail_callee, *callee);
}

class_use *build_class_use(rb_trace_arg_t *tracearg, class_use **caller) {
  class_use *new_use = malloc(sizeof(class_use));
  VALUE path = rb_tracearg_path(tracearg);

  new_use->caller = NULL;
  new_use->head_callee = NULL;
  new_use->tail_callee = NULL;

  new_use->name = class_name(rb_tracearg_self(tracearg));
  new_use->path = rb_string_value_ptr(&path);
  new_use->method = rb_id2name(rb_tracearg_callee_id(tracearg));
  new_use->lineno = FIX2INT(rb_tracearg_lineno(tracearg));

  add_callee_to_caller(&new_use, caller);

  return new_use;
}

void build_classes_stack(rb_trace_arg_t *tracearg) {
  class_use *new_use;

  new_use = build_class_use(tracearg, &top->class_use);
  push(&top, new_use);
}

void process_event(VALUE self, VALUE trace_point) {
  rb_trace_arg_t *tracearg = rb_tracearg_from_tracepoint(trace_point);
  rb_event_flag_t event = rb_tracearg_event_flag(tracearg);

  if (event == RUBY_EVENT_CALL || event == RUBY_EVENT_B_CALL) {
    // push_to_stack(tracearg);
  } else if (event == RUBY_EVENT_RETURN || event == RUBY_EVENT_B_RETURN) {
    // pop_stack_to_list();
  }
}
// TOP must be initialized
//
//
///* void print(struct classes_stack *top) {
//  VALUE* puts = malloc(sizeof(VALUE)*10);
//  puts[0] = rb_sprintf("%"PRIsVALUE"", rb_str_new_cstr(top->name));
//  rb_io_puts(1, puts, rb_stdout);
//} */
//
//
//void aggregate_uses(VALUE self) {
//  // while (top != NULL) pop_stack_to_list();
//}
//
///* VALUE *has_name(VALUE self, VALUE name_str) {
//  struct classes_list *curr = list_head;
//  char* str = StringValueCStr(name_str);
//  while (curr != NULL) {
//    if (strcmp(curr->curr->name, str) == 0) {
//      return rb_cTrueClass;
//    }
//    curr = curr->next;
//  }
//  return rb_cFalseClass;
//} */
//
//void init_event_processor(VALUE trace2) {
//  top = NULL;
//  list_head = NULL;
//  list_tail = NULL;
//  event_processor = rb_define_class_under(trace2, "EventProcessorC", rb_cObject);
//  rb_define_method(event_processor, "process_event", process_event, 1);
//  rb_define_method(event_processor, "aggregate_uses", aggregate_uses, 0);
//  /* rb_define_method(event_processor, "has_name", has_name, 1); */
//}
