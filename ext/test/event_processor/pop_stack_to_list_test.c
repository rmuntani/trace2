#include "../munit/munit.h"
#include "event_processor.h"
#include "test_helpers.h"

static void* 
pop_stack_to_list_setup_empty_head(const MunitParameter params[], void* user_data) {
  list_head = NULL;
  list_tail = NULL;
  top = malloc(sizeof(struct classes_stack));
  top->prev = NULL;
}

static void* 
pop_stack_to_list_setup_empty_tail(const MunitParameter params[], void* user_data) {
  list_tail = NULL;
  top = malloc(sizeof(struct classes_stack));
  top->prev = NULL;
  list_head = malloc(sizeof(struct classes_list));
  list_head->curr = malloc(sizeof(struct classes_stack));
  list_head->next = NULL;
}

static void* 
pop_stack_to_list_setup(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(struct classes_stack));
  top->prev = NULL;

  list_head = malloc(sizeof(struct classes_list));
  list_tail =  malloc(sizeof(struct classes_list));

  list_tail->curr = malloc(sizeof(struct classes_stack));
  list_tail->next = NULL;

  list_head->curr = malloc(sizeof(struct classes_stack));
  list_head->next = list_tail;
}

static void
pop_stack_to_list_tear_down(void *fixture) {
  clear_stack();
  clear_list();
}

MunitResult 
pop_stack_to_list_empty_head(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;

  pop_stack_to_list();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(original_top, list_head->curr);
  munit_assert_ptr_equal(list_head->next, NULL);
  munit_assert_ptr_equal(list_tail, NULL);

  return MUNIT_OK;
}

MunitResult 
pop_stack_to_list_empty_tail(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;

  pop_stack_to_list();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(list_head->next, list_tail);
  munit_assert_ptr_equal(list_tail->curr, original_top);
  munit_assert_ptr_equal(list_tail->next, NULL);

  return MUNIT_OK;
}

MunitResult 
pop_stack_to_list_full(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;
  struct classes_list *original_tail = list_tail;

  pop_stack_to_list();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_not_equal(list_head->next, list_tail);
  munit_assert_ptr_not_equal(original_tail, list_tail);
  munit_assert_ptr_equal(list_tail->curr, original_top);
  munit_assert_ptr_equal(list_tail->next, NULL);

  return MUNIT_OK;
}

MunitTest pop_stack_to_list_tests[] = {
  {
    "when classes list head is empty",
    pop_stack_to_list_empty_head,
    pop_stack_to_list_setup_empty_head,
    pop_stack_to_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when classes list tail is not empty",
    pop_stack_to_list_empty_tail,
    pop_stack_to_list_setup_empty_tail,
    pop_stack_to_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when classes list head and tail exists",
    pop_stack_to_list_full,
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
