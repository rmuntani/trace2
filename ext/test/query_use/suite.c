#include "munit/munit.h"
#include "validations_test.h"
#include "run_validations_test.h"
#include "run_actions_test.h"
#include "count_occurrences_test.h"
#include "find_position_test.h"

#define NUMBER_OF_SUITES 5

MunitSuite *query_use_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *query_use = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = validations_suite;
  *suite++;
  *suite = run_validations_suite;
  *suite++;
  *suite = run_actions_suite;
  *suite++;
  *suite = count_occurrences_suite;
  *suite++;
  *suite = find_position_suite;

  query_use->prefix =  "query_use ";
  query_use->tests = NULL;
  query_use->iterations = 1;
  query_use->options = MUNIT_SUITE_OPTION_NONE;
  query_use->suites = suite_head;

  return query_use;
}
