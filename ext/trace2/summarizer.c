#include "ruby.h"

VALUE summarizer;

void run(VALUE self) {
}

void init_summarizer(VALUE trace2) {
  summarizer = rb_define_class_under(trace2, "Summarizer", rb_cObject);
  rb_define_method(summarizer, "run", run, 0);
}
