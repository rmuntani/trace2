#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"
#include "summarizer.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

VALUE summarizer;
extern classes_list *list_head;

/* find_class_method_with_name: given a callee name, searches a list
 * for a summary that has that callee name. returns the matching
 * summarized_callees item or NULL */
list *find_class_method_with_name(list *class, char* name) {
  list *curr_class = class;

  for(curr_class = class; curr_class != NULL; curr_class = curr_class->next) {
    class_methods *curr_class_method = (class_methods*)curr_class->value;
    if (strcmp(curr_class_method->name, name) == 0) return curr_class;
  }

  return curr_class;
}

/* insert_node: create a new node on a list using it's
 * head and tail nodes */
void insert_node(list **head, list **tail) {
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
      insert_node(&head_callee, &tail_callee);
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

/* find_summary_with_use_name: given a list o summaries, look for a
* summarized_use that has an use with the "name" parameter. Returns
* NULL if no such summarized_use exists */
list *find_summary_with_use_name(list* summaries, char* name) {
  list *curr_summary;

  for(curr_summary = summaries; curr_summary != NULL; curr_summary = curr_summary->next) {
    summarized_use *summary = (summarized_use*)curr_summary->value;
    if (strcmp(summary->use->name, name) == 0) return curr_summary;
  }

  return curr_summary;
}

/* reduce_methods_list: given two lists in which each node has a 
 * char* value, inserts on the first list elements of the second 
 * list that aren't on the first list */
void *reduce_methods_list(list* first_list, list* second_list) {
  list *curr_snd_method = second_list;

  while(curr_snd_method != NULL) {
    list *next_method = curr_snd_method->next,
         *matching_method;

    matching_method = find_method_with_name_or_tail(first_list, method_name(curr_snd_method));

    // if the method is not on the list, add it
    if(strcmp(method_name(matching_method), method_name(curr_snd_method)) != 0) {
      matching_method->next = curr_snd_method;
      curr_snd_method->next = NULL;
    }

    curr_snd_method = next_method;
  }
}

/* reduce_class_methods_list: given two lists in which each node has a 
 * class_methods* value, inserts on the first list elements of the second 
 * list that aren't on the first list */
void *reduce_class_methods_list(list* first_list, list* second_list) {
  list *fst_tail, *curr_snd_item = second_list;

  for(fst_tail = first_list; fst_tail->next != NULL; fst_tail = fst_tail->next) {}

  while(curr_snd_item != NULL) {
    list *next_item = curr_snd_item->next, *matching_item;
    class_methods *curr_class = (class_methods*)curr_snd_item->value;

    matching_item = find_class_method_with_name(first_list, curr_class->name);

    // when class_method doesn't exist
    if(matching_item == NULL) {
      fst_tail->next = curr_snd_item;
      curr_snd_item->next = NULL;
      fst_tail = curr_snd_item;
    } else {
      class_methods *matching_class = (class_methods*)matching_item->value;
      reduce_methods_list(matching_class->methods, curr_class->methods);
    }
    curr_snd_item = next_item;
  }
}

/* reduce_summarized_uses: given a list of summarized_use, reduce elements
 * that have the same use->name into a single element by reducing their
 * use->methods, callees and callers into a single list */
list *reduce_summarized_uses(list *summaries) {
  if(summaries == NULL) {
    return NULL;
  } else {
    list *reduced_summaries = NULL, *tail_reduced_summaries = NULL,
         *curr_summary;

    // loop through all non-reduced summaries
    for(curr_summary = summaries; curr_summary != NULL; curr_summary = curr_summary->next) {
      // look for summary with name that is equal to current summary
      summarized_use *summary = (summarized_use*)curr_summary->value;
      list* matching_item = find_summary_with_use_name(reduced_summaries, summary->use->name);

      // when there is no summarized_use with current summary's name
      if(matching_item == NULL) {
        insert_node(&reduced_summaries, &tail_reduced_summaries);
        tail_reduced_summaries->value = (void*)summary;
      } else {
        summarized_use *matching_summary = (summarized_use*)matching_item->value;

        reduce_class_methods_list(matching_summary->callers, summary->callers);
        reduce_class_methods_list(matching_summary->callees, summary->callees);
        reduce_methods_list(matching_summary->use->methods, summary->use->methods);
      }
    }
    return reduced_summaries;
  }
}

void run(VALUE self) {}

void init_summarizer(VALUE trace2) {
  summarizer = rb_define_class_under(trace2, "Summarizer", rb_cObject);
  rb_define_method(summarizer, "run", run, 0);
}
