#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"
#include "munit/munit.h"

#define NAME 0
#define METHOD 1
#define PATH 2
#define LINENO 3
#define CALLER 4

#define NONE (-1)
#define ALLOW 0
#define REJECT 1

typedef struct validation {
  int (*function)(class_use*, void*);
  void* values;
} validation;

typedef struct action {
  short type;
  short num_validations;
  validation **validations;
} action;

int valid_name(class_use *use, void* names_ptr) {
  char** names = names_ptr;
  while(*names != NULL) {
    if (strcmp(use->name, *names) == 0) return 1;
    names++;
  }
  return 0;
}

int valid_method(class_use *use, void* methods_ptr) {
  char** methods = methods_ptr;
  while(*methods != NULL) {
    if (strcmp(use->method, *methods) == 0) return 1;
    methods++;
  }
  return 0;
}

int valid_path(class_use *use, void* paths_ptr) {
  char** paths = paths_ptr;
  while(*paths != NULL) {
    if (strcmp(use->path, *paths) == 0) return 1;
    paths++;
  }
  return 0;
}

int valid_lineno(class_use *use, void* linenos_ptr) {
  int* linenos = linenos_ptr;
  while(*linenos != 0) {
    if (*linenos == use->lineno) return 1;
    linenos++;
  }
  return 0;
}

int run_validations(validation *validations, class_use *use) {
  int valid = 1;
  while(valid == 1 && validations != NULL && validations->function != NULL) {
    valid &= (validations->function)(use, validations->values);
    validations++;
  }
  return valid;
}

int run_actions(action *actions, class_use *use) {
  int valid = 1;
  while(valid == 1 && actions != NULL && actions->type != NONE) {
    int i, curr_valid = 0;
    validation *curr_validations = *(actions->validations);

    for(i = 0; i < actions->num_validations && !curr_valid; i++) {
      curr_valid |= run_validations(curr_validations, use);
      curr_validations++;
    }

    valid &= (curr_valid ^ actions->type) & 1;
    actions++;
  }

  return valid;
}
