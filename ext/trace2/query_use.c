#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"
// TODO: eventually remove this header
// #include "munit/munit.h"

#define NAME 0
#define METHOD 1
#define PATH 2
#define LINENO 3
#define CALLER 4

// possible types of an action
#define UNDEFINED (-2)
#define NONE (-1)
#define ALLOW 0
#define REJECT 1

#define NOT_IMPLEMENTED -1
#define NAME 0
#define METHOD 1
#define PATH 2
#define LINENO 3
#define TOP_OF_STACK 4
#define BOTTOM_OF_STACK 5

typedef struct validation {
  int (*function)(class_use*, void*);
  void* values;
} validation;

typedef struct action {
  short type;
  short num_validations;
  validation **validations;
} action;

typedef struct filter {
  short num_actions;
  action *actions;
} filter;

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

int valid_top_of_stack(class_use *use, void* is_top) {
  int valid = ((use->head_callee == NULL) == *((int*)is_top));
  return valid;
}

int valid_bottom_of_stack(class_use *use, void* is_bottom) {
  int valid = ((use->caller == NULL) == *((int*)is_bottom));
  return valid;
}

static int valid_not_implemented(class_use *use, void* nothing) {
  return 1;
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

static char **duplicate_words_array(char** array, int start, int end) {
  int i = 0;
  char **dup_array = malloc(sizeof(char*)*(end - start + 2));

  for(i = 0; i + start <= end; i++) {
    dup_array[i] = array[i + start];
  }
  dup_array[i] = NULL;

  return dup_array;
}

static int *duplicate_int_array(char** array, int start, int end) {
  int i = 0;
  int *dup_array = malloc(sizeof(int)*(end - start + 2));

  for(i = 0; i + start <= end; i++) {
    dup_array[i] = atoi(array[i + start]);
  }
  dup_array[i] = 0;

  return dup_array;
}

static int validation_type(char *type) {
  if (strcmp(type, "validate_lineno") == 0) return LINENO;
  else if (strcmp(type, "validate_name") == 0) return NAME;
  else if (strcmp(type, "validate_path") == 0) return PATH;
  else if (strcmp(type, "validate_method") == 0) return METHOD;
  else if (strcmp(type, "validate_top_of_stack") == 0) return TOP_OF_STACK;
  else if (strcmp(type, "validate_bottom_of_stack") == 0) return BOTTOM_OF_STACK;
  else return NOT_IMPLEMENTED;
}

static void setup_validation(char **filter, int *pos, validation *curr_validation) {
  int num_values = atoi(filter[*pos + 1]), type;

  type = validation_type(filter[*pos]);
  curr_validation->values = malloc(sizeof(void*)*(num_values + 1));
  (*pos) += 2;

  if(type == LINENO) {
    curr_validation->function = valid_lineno;
    curr_validation->values = (void*)duplicate_int_array(filter, *pos, *pos + num_values);
  } else if(type == NAME || type == PATH || type == METHOD) {
    if(type == NAME) curr_validation->function = valid_name;
    else if(type == PATH) curr_validation->function = valid_path;
    else curr_validation->function = valid_method;

    curr_validation->values = (void*)duplicate_words_array(filter, *pos, *pos + num_values);
  } else if (type == TOP_OF_STACK || type == BOTTOM_OF_STACK) {
    int *value = malloc(sizeof(int));
    if(type == TOP_OF_STACK) curr_validation->function = valid_top_of_stack;
    else if(type == BOTTOM_OF_STACK) curr_validation->function = valid_bottom_of_stack;

    *value = (strcmp(filter[*pos], "true") == 0) ? 1 : 0;

    curr_validation->values= (int*)value;
  } else {
    curr_validation->values = NULL;
    curr_validation->function = valid_not_implemented;
  }

  (*pos) += num_values - 1;
}

static filter *initialize_filters(int num_filters) {
  int i;
  filter* filters = malloc(sizeof(filter)*(num_filters + 1));
  for(i = 0; i < num_filters; i++) {
    // -1 is used due to it's all num_actions being equal or greater than 0
    (filters[i]).num_actions = -1;
  }
  (filters[num_filters]).num_actions = 0;

  return filters;
}

static action *initialize_actions(int num_actions) {
  int i;
  action* actions = malloc(sizeof(action)*(num_actions + 1));
  for(i = 0; i < num_actions; i++) {
    (actions[i]).type = UNDEFINED;
  }
  (actions[num_actions]).type = NONE;

  return actions;
}

static validation **initialize_validations(int num_validations) {
  int i;
  validation** validations = malloc(sizeof(validation*)*(num_validations + 1));

  for(i = 0; i < num_validations; i++) {
    // (void*) 1 is used to make (vaidation[i] != NULL) false
    validations[i] = (void*) 1;
  }
  validations[num_validations] = NULL;

  return validations;
}

static validation *initialize_validation(int num_validation) {
  int i;
  validation* curr_validation = malloc(sizeof(validation)*(num_validation + 1));

  for(i = 0; i < num_validation; i++) {
    (curr_validation[i]).function = valid_not_implemented;
  }
  (curr_validation[num_validation]).function = NULL;

  return curr_validation;
}

filter* build_filters(char** filter_array) {
  filter *filters, *curr_filter;
  action *actions, *curr_action;
  validation **validations, *curr_validation,
             **curr_validations;
  int num_filters, num_actions, num_parallel_validations,
      num_validations, i = 1;

  num_filters = atoi(filter_array[0]);
  filters = initialize_filters(num_filters);

  for(curr_filter = filters; curr_filter->num_actions != 0; curr_filter++) {
    num_actions = atoi(filter_array[i]);
    actions = initialize_actions(num_actions);

    curr_filter->actions = actions;
    curr_filter->num_actions = num_actions;

    for(curr_action = actions; curr_action->type != NONE; curr_action++) {
      i++;
      num_parallel_validations = atoi(filter_array[i]);
      validations = initialize_validations(num_parallel_validations);

      curr_action->num_validations = num_parallel_validations;
      curr_action->validations = validations;

      for(curr_validations = validations;
          *curr_validations != NULL;
          curr_validations++) {
        i++;
        num_validations = atoi(filter_array[i]);

        *curr_validations = initialize_validation(num_validations);

        for(curr_validation = *curr_validations;
            curr_validation->function != NULL;
            curr_validation++) {
          i++;
          // setup_validation also increases current array position
          setup_validation(filter_array, &i, curr_validation);
        }
      }
      i++;
      if(strcmp(filter_array[i], "allow") == 0) {
        curr_action->type = ALLOW;
      } else {
        curr_action->type = REJECT;
      }
    }
    i++;
    if(strcmp(filter_array[i], "filter") == 0) i++;
  }
  return filters;
}

class_use *run_filters(filter* filters, class_use *use) {
  filter *curr_filter = filters;
  class_use *filtered_use = use;

  while(filtered_use != NULL && curr_filter->num_actions != 0) {
    int valid = run_actions(curr_filter->actions, filtered_use);
    filtered_use = valid ? filtered_use : NULL;
    curr_filter++;
  }

  return filtered_use;
}
