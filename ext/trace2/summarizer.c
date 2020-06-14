#include <stdlib.h>
#include "ruby.h"
#include "event_processor.h"
#include "summarizer.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

VALUE summarizer;

/* find_summary_with_name: given a name, searches a list for a summary that has
 * that name. returns the matching summarized_list item or NULL */
summarized_list *find_summary_with_name(summarized_list *summary, char* name) {
  summarized_list *curr_summary = summary;

  for(curr_summary = summary;
      curr_summary != NULL &&
      strcmp(curr_summary->name, name) != 0;
      curr_summary = curr_summary->next) {}

  return curr_summary;
}

/* push_summary_item: push a new summarized_list item into a linked list */
void push_summary_item(summarized_list **head, summarized_list **tail) {
  if (*head == NULL) {
    *head = malloc(sizeof(summarized_list));
    *tail = *head;
  } else if ((*head)->next == NULL) {
    (*head)->next = malloc(sizeof(summarized_list));
    *tail = (*head)->next;
  } else {
    (*tail)->next = malloc(sizeof(summarized_list));
    *tail = (*tail)->next;
  }
}

/* find_method_with_name: given a name, searches a list for a method that has
 * that name. returns the matching methods_list item or NULL */
methods_list *find_method_with_name(methods_list *methods, char* name) {
  methods_list *curr_method;

  for(curr_method = methods;
      curr_method != NULL && strcmp(curr_method->name, name) != 0;
      curr_method = curr_method->next) {}

  return curr_method;
}

/* reduce_uses_list: reduces a list of classes uses to a format that is
 * used on the generation on a new class use */

/* That function uses inefficient data structures and algorithms,
 * which may result in bad performance. If that is the case,
 * a better implementation should be used */
summarized_list *reduce_uses_list(classes_list* list) {
  summarized_list *summary = NULL, *summary_tail,
                  *curr_summary;
  classes_list* curr_item = list;

  while(curr_item != NULL) {
    curr_summary = find_summary_with_name(summary, curr_item->class_use->name);

    // when the summary with current class' item still doesn't exit
    if(curr_summary == NULL) {
      push_summary_item(&summary, &summary_tail);

      summary_tail->name = curr_item->class_use->name;

      // initialize the methods list with the current value
      summary_tail->methods = malloc(sizeof(methods_list));
      summary_tail->methods->name = curr_item->class_use->method;
      summary_tail->methods->next = NULL;

      summary_tail->next = NULL;
    } else {
      methods_list *curr_method;
      curr_method = find_method_with_name(curr_summary->methods,
                                          curr_item->class_use->method);

      // if the current method's name doesn't exist, create it
      if(curr_method == NULL) {
        methods_list *new_method = malloc(sizeof(methods_list));

        new_method->next = NULL;
        new_method->name = curr_item->class_use->method;

        curr_summary->methods->next = new_method;
      }
    }

    curr_item = curr_item->next;
  }

  return summary;
}

void run(VALUE self) {
}

void init_summarizer(VALUE trace2) {
  summarizer = rb_define_class_under(trace2, "Summarizer", rb_cObject);
  rb_define_method(summarizer, "run", run, 0);
}
