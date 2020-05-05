#include "munit/munit.h"
#include "pop_test.h"
#include "insert_test.h"
#include "add_callee_to_caller_test.h"
#include "push_test.h"
#include "pop_stack_to_list_test.h"
#include "push_new_class_use_test.h"
#include "clear_test.h"

#define NUMBER_OF_SUITES 7

MunitSuite *event_processor_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *event_processor = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = pop_suite;
  suite++;
  *suite = insert_suite;
  suite++;
  *suite = add_callee_to_caller_suite;
  suite++;
  *suite = push_suite;
  suite++;
  *suite = pop_stack_to_list_suite;
  suite++;
  *suite = push_new_class_use_suite;
  suite++;
  *suite = clear_suite;

  event_processor->prefix =  "event_processor ";
  event_processor->tests = NULL;
  event_processor->iterations = 1;
  event_processor->options = MUNIT_SUITE_OPTION_NONE;
  event_processor->suites = suite_head;

  return event_processor;
}
