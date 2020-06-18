struct class_use;
typedef struct class_use class_use;

struct classes_list;
typedef struct classes_list classes_list;

typedef struct methods_list {
  char* name;
  struct methods_list *next;
} methods_list;

typedef struct summarized_callees {
  char* caller;
  char* callee;
  struct methods_list *methods;
  struct summarized_callees *next;
} summarized_callees;

void init_summarizer(VALUE);
summarized_callees *reduce_callees_list(classes_list*);
