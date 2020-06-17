typedef struct methods_list {
  char* name;
  struct methods_list *next;
} methods_list;

typedef struct summarized_list {
  char* caller;
  char* callee;
  struct methods_list *methods;
  struct summarized_list *next;
} summarized_list;

void init_summarizer(VALUE);
