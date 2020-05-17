typedef struct class_use {
  char* name;
  char* method;
  char* path;
  int lineno;
  struct class_use* caller;
  struct classes_list* head_callee;
  struct classes_list* tail_callee;
} class_use;

typedef struct classes_list {
  struct classes_list *next;
  class_use *class_use;
} classes_list;

void init_event_processor(VALUE);
