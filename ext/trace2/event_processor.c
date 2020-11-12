#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "ruby/ruby.h"
#include "ruby/debug.h"
#include "name_finder.h"
#include "event_processor.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

struct filter;
typedef struct filter filter;
filter* build_filters(char**);
class_use *run_filters(filter*, class_use*);

typedef struct classes_stack {
  struct classes_stack *prev;
  class_use *class_use;
} classes_stack;

classes_list *list_head;
classes_list *list_tail;
classes_stack *top;
filter *curr_filter;

int accepted_uses;

VALUE event_processor;
VALUE event_symbols;

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
  if (*callee && caller && *caller) {
    (*callee)->caller = *caller;
    insert(&(*caller)->head_callee, &(*caller)->tail_callee, *callee);
  } else if (*callee) {
    (*callee)->caller = NULL;
  }
}

__attribute__((weak)) class_use *build_class_use(rb_trace_arg_t *tracearg, class_use **caller) {
  class_use *new_use = malloc(sizeof(class_use));
  VALUE path = rb_tracearg_path(tracearg);
  VALUE method = rb_tracearg_callee_id(tracearg);

  new_use->caller = NULL;
  new_use->head_callee = NULL;
  new_use->tail_callee = NULL;


  new_use->name = class_name(rb_tracearg_self(tracearg));
  new_use->path = rb_string_value_ptr(&path);
  new_use->lineno = FIX2INT(rb_tracearg_lineno(tracearg));

  if (TYPE(method) != T_NIL) {
    new_use->method = rb_id2name(SYM2ID(method));
  } else {
    new_use->method = malloc(sizeof(char)*4);
    strcpy(new_use->method, "nil");
  }

  add_callee_to_caller(&new_use, caller);

  return new_use;
}

void clear_stack(classes_stack **top) {
  classes_stack *curr_top = (*top);
  while(curr_top != NULL) {
    (*top) = (*top)->prev;
    free(curr_top);
    curr_top = *top;
  }
  *top = NULL;
}

void clear_list(classes_list **head, classes_list **tail) {
  classes_list *curr_node = (*head);
  while(curr_node != *tail) {
    (*head) = (*head)->next;
    free(curr_node);
    curr_node = *head;
  }
  if (*tail != NULL) {
    free(*tail);
  }
  *head = NULL;
  *tail = NULL;
}

void push_new_class_use(rb_trace_arg_t *tracearg, classes_stack **top) {
  class_use *new_use;

  if (*top == NULL) {
    new_use = build_class_use(tracearg, NULL);
  } else {
    new_use = build_class_use(tracearg, &(*top)->class_use);
  }

  push(top, new_use);
}

void process_event(VALUE self, VALUE trace_point) {
  rb_trace_arg_t *tracearg = rb_tracearg_from_tracepoint(trace_point);
  rb_event_flag_t event = rb_tracearg_event_flag(tracearg);

  if (event == RUBY_EVENT_CALL || event == RUBY_EVENT_B_CALL) {
    push_new_class_use(tracearg, &top);

    if(curr_filter == NULL ||
        (curr_filter != NULL && run_filters(curr_filter, top->class_use) != NULL)) {
      insert(&list_head, &list_tail, top->class_use);
      accepted_uses++;
    }
  } else if (event == RUBY_EVENT_RETURN || event == RUBY_EVENT_B_RETURN) {
    pop(&top);
  }
}

void aggregate_uses(VALUE self) { };

VALUE list_classes_uses(VALUE self) {
  classes_list *curr = list_head;
  VALUE classes_uses;

  classes_uses = rb_ary_new();

  while (curr != NULL) {
    class_use *curr_use;
    VALUE string;

    curr_use = curr->class_use;

    if (curr_use->caller) {
      string = rb_sprintf("class: %s, lineno: %d, path: %s, caller: %s, method: %s", \
          curr_use->name, curr_use->lineno, curr_use->path, curr_use->caller->name, \
          curr_use->method);
    } else {
      string = rb_sprintf("class: %s, lineno: %d, path: %s, caller: nil, method: %s", \
          curr_use->name, curr_use->lineno, curr_use->path, curr_use->method);
    }

    rb_ary_push(classes_uses, string);

    curr = curr->next;
  }

  return classes_uses;
}

void initialize(VALUE self, VALUE filters) {
  long length = RARRAY_LEN(filters), i;
  char **filters_array = malloc(sizeof(char*)*(length + 1));

  for(i = 0; i < length; i++) {
    VALUE curr_value = rb_ary_entry(filters, i);
    if(TYPE(curr_value) == T_REGEXP) {
      // indirectly use Regex.to_s method
      VALUE curr_regex = rb_sprintf("%"PRIsVALUE"", curr_value);
      filters_array[i] = StringValueCStr(curr_regex);
    } else {
      filters_array[i] = StringValueCStr(curr_value);
    }
  }
  filters_array[length] = NULL;

  if(curr_filter != NULL) free(curr_filter);

  curr_filter = (length > 0) ? build_filters(filters_array) : NULL;
  clear_stack(&top);
  clear_list(&list_head, &list_tail);
  accepted_uses = 0;
}

void initialize_event_symbols() {
  int num_events = 4, i;
  char *symbols[] = { "call", "b_call", "return", "b_return", NULL };
  event_symbols = rb_ary_new();

  for(i = 0; i < num_events; i++) {
    rb_ary_push(event_symbols, ID2SYM(rb_intern(symbols[i])));
  }
}

VALUE return_event_symbols(VALUE self) {
  return event_symbols;
}

void init_event_processor(VALUE trace2) {
  accepted_uses = 0;
  top = NULL;
  list_head = NULL;
  list_tail = NULL;
  curr_filter = NULL;

  initialize_event_symbols();

  event_processor = rb_define_class_under(trace2, "EventProcessorC", rb_cObject);
  rb_define_method(event_processor, "initialize", initialize, 1);
  rb_define_method(event_processor, "process_event", process_event, 1);
  rb_define_method(event_processor, "aggregate_uses", aggregate_uses, 0);
  rb_define_method(event_processor, "classes_uses", list_classes_uses, 0);

  rb_define_const(event_processor, "EVENT", event_symbols);
  rb_define_method(event_processor, "events", return_event_symbols, 0);
}
