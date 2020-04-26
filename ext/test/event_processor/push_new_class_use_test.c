#include "../munit/munit.h"
#include "event_processor.h"
#include "test_helpers.h"

extern classes_stack *top;

class_use *build_class_use(rb_trace_arg_t *tracearg, class_use **caller) {
  class_use *new_use = malloc(sizeof(class_use));

  if (caller != NULL) {
    new_use->caller = *caller;
  }

  munit_log(MUNIT_LOG_WARNING, "OK");
  return new_use;
}

static void
push_new_class_use_tear_down(void *fixture) {
  clear_stack();
  clear_list();
}

static void* 
push_new_class_use_setup(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(classes_stack));
  top->class_use = malloc(sizeof(class_use));
  top->prev = NULL;
}

static void*
push_new_class_use_empty_stack_setup(const MunitParameter params[], void* user_data) {
  top = NULL;
}

MunitResult 
push_new_class_use_test(const MunitParameter params[], void* class_use_setup) {
  class_use *original_class_use = top->class_use;
  classes_stack *original_top = top;

  push_new_class_use(NULL, &top);

  munit_assert_ptr_equal(top->prev, original_top);
  munit_assert_ptr_equal(top->prev->prev, NULL);
  munit_assert_ptr_not_equal(top->class_use, NULL);
  munit_assert_ptr_equal(top->class_use->caller, original_class_use);

  return MUNIT_OK;
}

MunitResult 
push_new_class_use_empty_stack_test(const MunitParameter params[], void* class_use_setup) {
  push_new_class_use(NULL, &top);

  munit_assert_ptr_equal(top->prev, NULL);
  munit_assert_ptr_not_equal(top->class_use, NULL);
  munit_assert_ptr_equal(top->class_use->caller, NULL);

  return MUNIT_OK;
}

MunitTest push_new_class_use_tests[] = {
  {
    "when stack is not empty ",
    push_new_class_use_test,
    push_new_class_use_setup,
    push_new_class_use_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when stack is empty ",
    push_new_class_use_empty_stack_test,
    push_new_class_use_empty_stack_setup,
    push_new_class_use_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite push_new_class_use_suite = {
  "push_new_class_use ",
  push_new_class_use_tests,
  NULL, 
  1,
  MUNIT_SUITE_OPTION_NONE
};
