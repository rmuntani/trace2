#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"
#include "summarizer.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

VALUE summarizer;

/* find_class_method_with_name: given a callee name, searches a list
 * for a summary that has that callee name. returns the matching
 * summarized_callees item or NULL */
list *find_class_method_with_name(list *summary, char* name) {
  list *curr_summary = summary;

  for(curr_summary = summary; curr_summary != NULL; curr_summary = curr_summary->next) {
    class_methods *curr_class_method = (class_methods*)curr_summary->value;
    if (strcmp(curr_class_method->name, name) == 0) return curr_summary;
  }

  return curr_summary;
}

/* push_class_method_item: push a new list item into the linked list
 * "list" */
void push_class_method_item(list **head, list **tail) {
  if (*head == NULL) {
    *head = malloc(sizeof(list));
    (*head)->next = NULL;
    *tail = *head;
  } else if ((*head)->next == NULL) {
    (*head)->next = malloc(sizeof(list));
    *tail = (*head)->next;
    (*tail)->next = NULL;
  } else {
    (*tail)->next = malloc(sizeof(list));
    *tail = (*tail)->next;
    (*tail)->next = NULL;
  }
}

/* find_method_with_name_or_tail: given a name, searches a
 * for an item that has that value. returns the matching element,
 * or the tail of the list */
list *find_method_with_name_or_tail(list *methods, char* name) {
  list *curr_method;

  for(curr_method = methods;
      curr_method != NULL && curr_method->next != NULL &&
        strcmp(method_name(curr_method), name) != 0;
      curr_method = curr_method->next) {}

  return curr_method;
}

/* set_class_method: create a class_methods with the class use passed
 * as parameter. That doesn't include the parameter's caller and callees */
class_methods *set_class_method(class_use *use) {
  class_methods *new_class_method = malloc(sizeof(class_methods));

  new_class_method->methods = malloc(sizeof(list));
  new_class_method->name = use->name;
  new_class_method->methods->next = NULL;
  new_class_method->methods->value = (void*)use->method;

  return new_class_method;
}

/* summarize: reduces a list of classes uses to a format that is
 * used on the generation of a resport */

/* That function uses inefficient data structures and algorithms,
 * which may result in bad performance. If that is the case,
 * a better implementation should be used */
summarized_use *summarize(class_use *use) {
  summarized_use *summary = malloc(sizeof(summarized_use));
  class_methods *callee = malloc(sizeof(class_methods));
  classes_list *curr_callee = use->head_callee;
  list *tail_callee = NULL, *head_callee = NULL;

  summary->use = set_class_method(use);

  summary->callers = malloc(sizeof(list));
  summary->callers->value = (void*)set_class_method(use->caller);
  summary->callers->next = NULL;

  while(curr_callee != NULL) {
    list *curr_class = find_class_method_with_name(head_callee,
        curr_callee->class_use->name);

    // when class_method doesn't exist
    if(curr_class == NULL) {
      push_class_method_item(&head_callee, &tail_callee);
      tail_callee->value = (void*)set_class_method(curr_callee->class_use);
    } else {
      class_methods *class_with_name = (class_methods*)curr_class->value;
      list *methods = class_with_name->methods,
           *tail_method;

      tail_method = find_method_with_name_or_tail(methods, curr_callee->class_use->method);

      // when method name is not on the list
      if(strcmp(method_name(tail_method), curr_callee->class_use->method) != 0) {
        tail_method-> next = malloc(sizeof(list));
        tail_method->next->next = NULL;
        tail_method->next->value = (void*)curr_callee->class_use->method;
      }
    }
    curr_callee = curr_callee->next;
  }

  summary->callees = head_callee;

  return summary;
}

void run(VALUE self) {}

void init_summarizer(VALUE trace2) {
  summarizer = rb_define_class_under(trace2, "Summarizer", rb_cObject);
  rb_define_method(summarizer, "run", run, 0);
}
