struct class_use;
typedef struct class_use class_use;

struct classes_list;
typedef struct classes_list classes_list;

typedef struct methods_list {
  char* name;
  struct methods_list *next;
} methods_list;

typedef struct summarized_list {
  char* name;
  struct methods_list *methods;
  struct summarized_list *next;
} summarized_list;

void init_summarizer(VALUE);
summarized_list *reduce_uses_list(classes_list*);
