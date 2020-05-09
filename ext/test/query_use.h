typedef struct validation {
  int (*function)(class_use*, void*);
  void* values;
} validation;

int valid_name(class_use*, void*);
int valid_method(class_use*, void*);
int valid_path(class_use*, void*);
int valid_lineno(class_use*, void*);

int run_validations(validation*, class_use*);
