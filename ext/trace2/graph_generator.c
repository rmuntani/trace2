#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ruby.h"
#include "event_processor.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

VALUE graph_generator;

/* count_relationships: given a class_use as a parameter, this function
 * returns the number of callees and callers that the class use has.*/
int count_relationships(class_use *use) {
  classes_list *curr_use = use->head_callee;
  int count;

  for(count = 0; curr_use != NULL; count++, curr_use = curr_use->next);

  if(use->caller) count++;

  return count;
}

/* make_graph_string: with a caller name and a callee name, this function
 * returns a null-terminated string with format "CALLER -> CALLEE" */
char* make_graph_string(char *caller_name, char *callee_name) {
  char *graph_string;
  int total_length = strlen(callee_name) + strlen(caller_name) + 5;

  graph_string = malloc(sizeof(total_length));
  sprintf(graph_string, "%s -> %s", callee_name, caller_name);

  return graph_string;
}

/* graph_strings: with a class_use, returns an array of strings that
 * has strings with format "CALLER -> CALLEE". The array of strings
 * ends with a NULL pointer */
char** graph_strings(class_use* use) {
  if (use->caller == NULL && use->head_callee == NULL) {
    char **graph_strings = malloc(sizeof(char*));

    *graph_strings = NULL;

    return graph_strings;
  } else {
    classes_list *curr_use = use->head_callee;
    int total_strings = count_relationships(use),
        curr_string = 0;
    char **graph_strings = malloc(sizeof(char*)*(total_strings + 1));

    if(use->caller) {
      *graph_strings = make_graph_string(use->name, use->caller->name);
      curr_string++;
    }

    for(;curr_use != NULL; curr_use = curr_use->next, curr_string++) {
      char *caller_name = curr_use->class_use->name,
           *callee_name = use->name;
      *(graph_strings + curr_string) = make_graph_string(caller_name, callee_name);
    }

    *(graph_strings + total_strings) = NULL;

    return graph_strings;
  }
}

/* init_graph_generator: initializes the Ruby classes, modules and functions
 * related to Trace2::GraphGenerator */
void init_graph_generator(VALUE trace2) {
  graph_generator = rb_define_module_under(trace2, "GraphGenerator");
}
