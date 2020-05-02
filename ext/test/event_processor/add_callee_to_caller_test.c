/* The test in this file covers a single use case of add_callee_to_caller,
 * due to the function being quite simple and depending mostly on
 * event_processor's insert. */
#include "../munit/munit.h"
#include "event_processor.h"

class_use *caller;
class_use *callee;

static void
add_callee_to_caller_tear_down(void *fixture) {
  free(caller);
  free(callee);
}

static void*
add_callee_to_caller_setup(const MunitParameter params[], void* user_data) {
  caller = malloc(sizeof(class_use));
  caller->head_callee = NULL;
  caller->tail_callee = NULL;

  callee = malloc(sizeof(class_use));
  callee->head_callee = NULL;
  callee->tail_callee = NULL;
}

MunitResult
add_callee_to_caller_test(const MunitParameter params[], void* user_data_or_fixture) {
  add_callee_to_caller(&callee, &caller);

  munit_assert_ptr_equal(callee->caller, caller);
  munit_assert_ptr_equal(caller->head_callee->class_use, callee);
  munit_assert_ptr_equal(caller->tail_callee, NULL);

  return MUNIT_OK;
}

static void*
add_empty_callee_to_caller_setup(const MunitParameter params[], void* user_data) {
  caller = malloc(sizeof(class_use));
  caller->head_callee = NULL;
  caller->tail_callee = NULL;

  callee = NULL;
}

MunitResult
add_empty_callee_to_caller_test(const MunitParameter params[], void* user_data_or_fixture) {
  add_callee_to_caller(&callee, &caller);

  munit_assert_ptr_equal(callee, NULL);
  munit_assert_ptr_equal(caller->head_callee, NULL);
  munit_assert_ptr_equal(caller->tail_callee, NULL);

  return MUNIT_OK;
}

static void*
add_callee_to_empty_caller_setup(const MunitParameter params[], void* user_data) {
  caller = NULL;

  callee = malloc(sizeof(class_use));
  callee->head_callee = NULL;
  callee->tail_callee = NULL;
}

MunitResult
add_callee_to_empty_caller_test(const MunitParameter params[], void* user_data_or_fixture) {
  add_callee_to_caller(&callee, &caller);

  munit_assert_ptr_equal(caller, NULL);
  munit_assert_ptr_equal(callee->caller, NULL);

  return MUNIT_OK;
}

static void*
add_callee_to_null_caller_setup(const MunitParameter params[], void* user_data) {
  caller = NULL;

  callee = malloc(sizeof(class_use));
  callee->head_callee = NULL;
  callee->tail_callee = NULL;
}

MunitResult
add_callee_to_null_caller_test(const MunitParameter params[], void* user_data_or_fixture) {
  add_callee_to_caller(&callee, NULL);

  munit_assert_ptr_equal(callee->caller, NULL);

  return MUNIT_OK;
}

MunitTest add_callee_to_caller_tests[] = {
  {
    "when both caller and callee exist",
    add_callee_to_caller_test,
    add_callee_to_caller_setup,
    add_callee_to_caller_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when callee is empty ",
    add_empty_callee_to_caller_test,
    add_empty_callee_to_caller_setup,
    add_callee_to_caller_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when caller is empty ",
    add_callee_to_empty_caller_test,
    add_callee_to_empty_caller_setup,
    add_callee_to_caller_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when caller is null",
    add_callee_to_null_caller_test,
    add_callee_to_null_caller_setup,
    add_callee_to_caller_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite add_callee_to_caller_suite = {
  "add_callee_to_caller ",
  add_callee_to_caller_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
