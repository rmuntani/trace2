typedef unsigned long rb_event_flag_t;

typedef struct {
  int num;
  char* str;
  void* tracearg;
  int type;
} VALUE;

typedef struct {
  VALUE path;
  VALUE self;
  VALUE callee_id;
  VALUE lineno;
  rb_event_flag_t event_flag;
} rb_trace_arg_t;

rb_trace_arg_t *tracearg_mock;
VALUE rb_cObject;

VALUE rb_tracearg_self(rb_trace_arg_t* tracearg) {
  return tracearg->self;
}

VALUE rb_tracearg_path(rb_trace_arg_t* tracearg) {
  return tracearg->path;
}

char* rb_string_value_ptr(VALUE* str_klass) {
  return str_klass->str;
}

VALUE rb_tracearg_callee_id(rb_trace_arg_t* tracearg) {
  return tracearg->callee_id;
}

char* rb_id2name(VALUE id) {
  return id.str;
}

VALUE rb_tracearg_lineno(rb_trace_arg_t* tracearg) {
  return tracearg->lineno;
}

int FIX2INT(VALUE integer) {
  return integer.num;
}

rb_trace_arg_t* rb_tracearg_from_tracepoint(VALUE tracepoint) {
  return tracearg_mock;
}

rb_event_flag_t rb_tracearg_event_flag(rb_trace_arg_t* tracearg) {
  return tracearg->event_flag;
}

VALUE rb_define_class_under(VALUE class, char* name, VALUE super_class) { return class; }

void rb_define_method(VALUE class, const char* name, void (*argv)(), int argc) { }

int TYPE(VALUE obj) {
  return obj.type;
}

char* rb_class2name(VALUE obj) {
  return obj.str;
}

char *rb_obj_classname(VALUE obj) {
  return obj.str;
}

VALUE rb_str_new_cstr(const char* str) {
  VALUE str_class;
  str_class.str = str;
  return str_class;
}

VALUE rb_define_module_under(VALUE module, const char* str) {
  return module;
}

VALUE Qnil;

VALUE rb_sprintf(char* str, ...) {}

VALUE SYM2ID(VALUE symbol) {}

VALUE rb_ary_new() {}

VALUE rb_ary_push(VALUE array, VALUE value) {}
