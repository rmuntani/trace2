#include <stdlib.h>
#include <summarizer.h>

class_methods *create_fixture_class_methods(char* name, char** methods) {
  class_methods *fixture = malloc(sizeof(class_methods));
  list *tail_method = malloc(sizeof(list));
  char** curr_method;

  fixture->name = name;
  fixture->methods = NULL;

  for(curr_method = methods; *curr_method != NULL; *curr_method++) {
    if(fixture->methods == NULL) {
      fixture->methods = tail_method;
    } else {
      tail_method->next = malloc(sizeof(list));
      tail_method = tail_method->next;
    }
    tail_method->value = (void*)*curr_method;
    tail_method->next = NULL;
  }

  return fixture;
}

list *wrap_list(void* value) {
  list *wrapper = malloc(sizeof(list));

  wrapper->next = NULL;
  wrapper->value = (void*)value;

  return wrapper;
}

