#include "../munit/munit.h"
#include "event_processor.h"

classes_stack *top;

static void
push_tear_down(void *fixture) {
  clear_stack(&top);
}

static void*
push_setup(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(classes_stack));
  top->prev = NULL;
  top->class_use = malloc(sizeof(class_use));

  return malloc(sizeof(class_use));
}

MunitResult
push_test(const MunitParameter params[], void* class_use_setup) {
  classes_stack *original_stack = top;

  push(&top, (class_use*)class_use_setup);

  munit_assert_ptr_equal(top->class_use, (class_use*)class_use_setup);
  munit_assert_ptr_equal(top->prev, original_stack);

  return MUNIT_OK;
}

static void*
empty_push_setup(const MunitParameter params[], void* user_data) {
  top = NULL;
  return malloc(sizeof(class_use));
}

MunitResult
empty_push_test(const MunitParameter params[], void* class_use_setup) {
  push(&top, class_use_setup);

  munit_assert_ptr_equal(top->prev, NULL);
  munit_assert_ptr_equal(top->class_use, class_use_setup);

  return MUNIT_OK;
}

MunitTest push_tests[] = {
  {
    "when stack is not empty ",
    push_test,
    push_setup,
    push_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when stack is empty ",
    empty_push_test,
    empty_push_setup,
    push_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite push_suite = {
  "push ",
  push_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
