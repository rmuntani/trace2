#define method_name(x) (char*)(x->value)

struct class_use;
typedef struct class_use class_use;

struct classes_list;
typedef struct classes_list classes_list;

typedef struct list {
  struct list* next;
  void* value;
} list;

typedef struct class_methods {
  char* name;
  list* methods;
} class_methods;

typedef struct summarized_use {
  list* callers;
  class_methods *use;
  list* callees;
} summarized_use;

summarized_use *summarize(class_use*);
void* reduce_class_methods_list(list*, list*);
list *reduce_summarized_uses(list*);
