#define NONE (-1)
#define ALLOW 0
#define REJECT 1

typedef struct validation {
  int (*function)(class_use*, void*);
  void* values;
} validation;

/* An action has a series of validations. It's first dimension
 * is used for validations that are executed in parallel. If
 * one of them is true, it suffices to return a 1 response.
 * The second dimension is for validations that are executed
 * in series. For it to be 1, all validations should be 1. */
typedef struct action {
  short type;
  short num_validations;
  validation **validations;
} action;

/* A filter can have up to two actions, and they must have
 * different types */
typedef struct filter {
  short num_actions;
  action *actions;
} filter;

int valid_name(class_use*, void*);
int valid_method(class_use*, void*);
int valid_path(class_use*, void*);
int valid_lineno(class_use*, void*);

int run_validations(validation*, class_use*);
int run_actions(action*, class_use*);

filter* build_filters(char**);
int count_occurrences(char*, char**, int, int);
int find_position(char*, char**, int);
