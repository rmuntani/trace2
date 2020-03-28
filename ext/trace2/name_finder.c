#include "ruby.h"
#include <stdlib.h>
#include <string.h>

VALUE name_finder;

const char* class_name(VALUE object) {
  if (TYPE(object) == T_MODULE || TYPE(object) == T_CLASS) {
    // variable.c rb_path_to_class uses this procedure to
    // throw errors for anonymous classes
    const char *class_name = rb_class2name(object), *pend;
    pend = class_name + strlen(class_name);

    if (class_name == pend || class_name[0] == '#') {
      const char *anonymous_name = rb_obj_classname(object);
      char *final_name = malloc((9+strlen(anonymous_name))*sizeof(char));

      strcpy(final_name, "Anonymous");
      strcat(final_name, anonymous_name);

      return final_name;
    }
    return class_name;
  } else {
    return rb_obj_classname(object);
  }
}

VALUE rb_class_name_str(VALUE self, VALUE object)
{
  return rb_str_new_cstr(class_name(object));
}

void init_name_finder(VALUE trace2) {
  name_finder = rb_define_module_under(trace2, "NameFinder");
  rb_define_method(rb_cObject, "class_name", rb_class_name_str, 1);
}
