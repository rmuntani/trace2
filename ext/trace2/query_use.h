struct class_use;
typedef struct class_use class_use;

struct validation;
typedef struct validation validation;

struct action;
typedef struct action action;

typedef struct filter {
  short num_actions;
  action *actions;
} filter;

filter* build_filters(char**);
class_use *run_filters(filter*, class_use*);
