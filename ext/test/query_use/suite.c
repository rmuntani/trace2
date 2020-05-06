#include "munit/munit.h"
#include "validations_test.h"

#define NUMBER_OF_SUITES 1

MunitSuite *query_use_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *query_use = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = validations_suite;

  query_use->prefix =  "query_use ";
  query_use->tests = NULL;
  query_use->iterations = 1;
  query_use->options = MUNIT_SUITE_OPTION_NONE;
  query_use->suites = suite_head;

  return query_use;
}
