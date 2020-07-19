#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ruby.h"
#include "event_processor.h"
#include "hash_table.h"
// TODO: eventually remove this header
#include "munit/munit.h"

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

/* build_graphs_array: given the list of classes uses, it builds the array
 * of strings that summarize the relationship between distinct classes.
 * It also uses the total_uses value to create a hashtable, which is used
 * to get unique elements of the array */
char** build_graphs_array(classes_list *head, int total_uses) {
  int unique_uses = 0, i, item_index = 0;
  classes_list *curr_use = head;
  char** graphs_array;
  hash_table *table = create_table(total_uses);

  // insert all elements on the hash table
  while(curr_use != NULL) {
    char **relationship_strings = graph_strings(curr_use->class_use),
         **curr_key;

    for(curr_key = relationship_strings;
        *curr_key!= NULL; curr_key++) {
      unique_uses += table_insert(table, (void*)0, *curr_key);
    }
    curr_use = curr_use->next;
  }
  // allocate memory for the array of strings
  graphs_array = malloc(sizeof(char*)*(unique_uses + 1));
  *(graphs_array + unique_uses) = NULL;

  // fill list of arrays
  for(i = 0; i < table->size; i++) {
    table_item *curr_item = table->table[i];

    for(;curr_item != NULL; curr_item = curr_item->next, item_index++) {
      *(graphs_array + item_index) = curr_item->key;
    }
  }

  return graphs_array;
}

/* init_graph_generator: initializes the Ruby classes, modules and functions
 * related to Trace2::GraphGenerator */
void init_graph_generator(VALUE trace2) {
  graph_generator = rb_define_module_under(trace2, "GraphGenerator");
}
