#include "munit/munit.h"
#include "graph_strings_test.h"

#define NUMBER_OF_SUITES 1

MunitSuite *graph_generator_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *graph_generator = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = graph_strings_suite;

  graph_generator->prefix =  "graph_generator ";
  graph_generator->tests = NULL;
  graph_generator->iterations = 1;
  graph_generator->options = MUNIT_SUITE_OPTION_NONE;
  graph_generator->suites = suite_head;

  return graph_generator;
}
