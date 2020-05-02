#include "../munit/munit.h"
#include "event_processor.h"

extern classes_stack *top;
extern classes_list *list_head;
extern classes_list *list_tail;

static void
pop_stack_to_list_tear_down(void *fixture) {
  clear_stack(&top);
  clear_list(&list_head, &list_tail);
}

static void*
pop_stack_to_list_setup(const MunitParameter params[], void* user_data) {
  list_head = malloc(sizeof(classes_stack));
  list_head->next = NULL;
  list_head->class_use = malloc(sizeof(class_use));
  list_tail = NULL;

  top = malloc(sizeof(classes_stack));
  top->class_use = malloc(sizeof(class_use));
  top->prev = NULL;
}

MunitResult
pop_stack_to_list_test(const MunitParameter params[], void* class_use_setup) {
  class_use *original_class_use = top->class_use;

  pop_stack_to_list(&top, &list_head, &list_tail);

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(list_tail->class_use, original_class_use);
  munit_assert_ptr_equal(list_head->next, list_tail);

  return MUNIT_OK;
}

MunitTest pop_stack_to_list_tests[] = {
  {
    "when stack is not empty ",
    pop_stack_to_list_test,
    pop_stack_to_list_setup,
    pop_stack_to_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite pop_stack_to_list_suite = {
  "pop_stack_to_list ",
  pop_stack_to_list_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
