#include "../munit/munit.h"
#include "event_processor.h"

classes_stack *top;
classes_list *head;
classes_list *tail;

static void*
clear_list_setup(const MunitParameter params[], void* user_data) {
  head = malloc(sizeof(classes_list));
  tail = malloc(sizeof(classes_list));
  head->next = tail;
}

static void*
clear_stack_setup(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(classes_stack));
  top->class_use = malloc(sizeof(class_use));
  top->prev = NULL;
}

MunitResult
clear_list_test(const MunitParameter params[], void* fixture) {
  clear_list(&head, &tail);

  munit_assert_ptr_equal(head, NULL);
  munit_assert_ptr_equal(tail, NULL);

  return MUNIT_OK;
}

MunitResult
clear_stack_test(const MunitParameter params[], void* fixture) {
  clear_stack(&top);

  munit_assert_ptr_equal(top, NULL);

  return MUNIT_OK;
}

MunitTest clear_tests[] = {
  {
    "clear a list ",
    clear_list_test,
    clear_list_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "clear a stack ",
    clear_stack_test,
    clear_stack_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite clear_suite = {
  "clear ",
  clear_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
