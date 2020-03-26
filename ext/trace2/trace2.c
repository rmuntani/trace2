#include "ruby.h"

VALUE traceC;
VALUE class_processor;

VALUE get_class_name(VALUE obj)
{
    VALUE str;
    VALUE cname = rb_class_name(rb_class_real(CLASS_OF(obj)));

    str = rb_sprintf("%"PRIsVALUE"", cname);
    return str;
}

void Init_trace2_c() {
  traceC = rb_define_module("TraceC");
  class_processor = rb_define_class_under(traceC, "ClassProcessor", rb_cObject);
  rb_define_module_function(traceC, "get_class_name", get_class_name, 0);
  rb_define_method(rb_cObject, "get_class_name", get_class_name, 0);
}
