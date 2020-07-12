#include "ruby.h"

VALUE graph_generator;

void init_graph_generator(VALUE trace2) {
  graph_generator = rb_define_module_under(trace2, "GraphGenerator");
}
