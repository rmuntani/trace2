typedef struct class_use {
  char* name;
  char* method;
  char* path;
  int lineno;
  struct class_use* caller;
  struct classes_list* head_callee;
  struct classes_list* tail_callee;
} class_use;

VALUE init_event_processor(VALUE);
