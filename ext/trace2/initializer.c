#include "ruby.h"
#include "name_finder.h"
#include "event_processor.h"
#include "query_use.h"
#include "graph_generator.h"

VALUE trace2;

void Init_trace2() {
  trace2 = rb_define_module("Trace2");
  init_name_finder(trace2);
  init_event_processor(trace2);
  init_graph_generator(trace2);
}
