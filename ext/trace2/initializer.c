#include "ruby.h"
#include "name_finder.h"
#include "event_processor.h"
#include "query_use.h"

VALUE trace2;

void Init_trace2_c() {
  trace2 = rb_define_module("Trace2");
  init_name_finder(trace2);
  init_event_processor(trace2);
}
