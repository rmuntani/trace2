#include "../munit/munit.h"
#include "event_processor.h"
#include "test_helpers.h"

extern classes_stack *top;

static void
pop_tear_down(void *fixture) {
  clear_stack();
}

static void* 
pop_setup(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(classes_stack)); 
  top->prev = NULL;
}

static void* 
pop_null_setup(const MunitParameter params[], void* user_data) {
  top = NULL; 
}

MunitResult 
pop_test(const MunitParameter params[], void* user_data_or_fixture) {
  classes_stack *popped, *original_top = top;

  popped = pop(&top);

  munit_assert_ptr(popped, ==, original_top);
  munit_assert_ptr_equal(top, NULL);

  return MUNIT_OK;
}

MunitResult
pop_null_test(const MunitParameter params[], void* user_data_or_fixture) {
  classes_stack *popped, *original_top = top;

  popped = pop(&top);

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(popped, NULL);

  return MUNIT_OK;
}

MunitTest pop_tests[] = {
  {
    "when stack is not empty ",
    pop_test,
    pop_setup,
    pop_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when stack is empty ",
    pop_null_test,
    pop_null_setup,
    pop_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite pop_suite = {
  "pop_stack ",
  pop_tests,
  NULL, 
  1,
  MUNIT_SUITE_OPTION_NONE
};
