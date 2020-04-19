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

void *insert(classes_list **head, classes_list **tail, class_use *class_use) {
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

//
//void insert_callee(struct classes_stack *top, struct classes_stack *new_top) {
//  struct classes_list *new_callee = malloc(sizeof(struct classes_list));
//  if (top == NULL) {
//    new_callee->next = NULL;
//  } else {
//    new_callee->next = top->callees;
//    top->callees = new_callee;
//  }
//  new_callee->class_use = new_top;
//}
//
//void push_to_stack(rb_trace_arg_t *tracearg) {
//  class_ *new_top = malloc(sizeof(struct classes_stack));
//  VALUE path;
//  new_top->name = class_name(rb_tracearg_self(tracearg));
//  path = rb_tracearg_path(tracearg);
//  new_top->path = rb_string_value_ptr(&path);
//  new_top->method = rb_id2name(rb_tracearg_callee_id(tracearg));
//  new_top->lineno = FIX2INT(rb_tracearg_lineno(tracearg));
//  new_top->prev = top;
//  insert_callee(top, new_top);
//  top = new_top;
//}
//
//void update_classes_stack(VALUE trace_point) {
//  rb_trace_arg_t *tracearg = rb_tracearg_from_tracepoint(trace_point);
//  rb_event_flag_t event = rb_tracearg_event_flag(tracearg);
//
//  if (event == RUBY_EVENT_CALL || event == RUBY_EVENT_B_CALL) {
//    push_to_stack(tracearg);
//  } else if (event == RUBY_EVENT_RETURN || event == RUBY_EVENT_B_RETURN) {
//    // pop_stack_to_list();
//  }
//}
//
//
///* void print(struct classes_stack *top) {
//  VALUE* puts = malloc(sizeof(VALUE)*10);
//  puts[0] = rb_sprintf("%"PRIsVALUE"", rb_str_new_cstr(top->name));
//  rb_io_puts(1, puts, rb_stdout);
//} */
//
//void process_event(VALUE self, VALUE trace_point) {
//  update_classes_stack(trace_point);
//}
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
