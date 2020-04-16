#include "../munit/munit.h"
#include "event_processor.h"
#include "test_helpers.h"

extern classes_stack *top;
extern classes_list *list_head;
extern classes_list *list_tail;

static void
insert_tear_down(void *fixture) {
  clear_list();
}

static void*
insert_null_head_setup(const MunitParameter params[], void* user_data) {
  list_head = NULL;
  list_tail = NULL;

  return malloc(sizeof(classes_stack));
}

MunitResult
insert_null_head_test(const MunitParameter params[], void* user_data_or_fixture) {

  insert(&list_head, &list_tail, (classes_stack*)user_data_or_fixture);

  munit_assert_ptr_equal(list_head->curr, user_data_or_fixture);
  munit_assert_ptr_equal(list_tail, NULL);

  return MUNIT_OK;
}

static void*
insert_null_tail_setup(const MunitParameter params[], void* user_data) {
  list_head = malloc(sizeof(classes_list));
  list_head->curr = malloc(sizeof(classes_stack));
  list_tail = NULL;

  return malloc(sizeof(classes_stack));
}

MunitResult
insert_null_tail_test(const MunitParameter params[], void* user_data_or_fixture) {

  insert(&list_head, &list_tail, (classes_stack*)user_data_or_fixture);

  munit_assert_ptr_equal(list_head->next, list_tail);
  munit_assert_ptr_equal(list_tail->curr, user_data_or_fixture);
  munit_assert_ptr_equal(list_tail->next, NULL);

  return MUNIT_OK;
}

static void*
insert_setup(const MunitParameter params[], void* user_data) {
  list_head = malloc(sizeof(classes_list));
  list_head->curr = malloc(sizeof(classes_stack));

  list_tail = malloc(sizeof(classes_list));
  list_tail->curr = malloc(sizeof(classes_stack));

  list_head->next = list_tail;

  return malloc(sizeof(classes_stack));
}

MunitResult
insert_test(const MunitParameter params[], void* user_data_or_fixture) {

  insert(&list_head, &list_tail, (classes_stack*)user_data_or_fixture);

  munit_assert_ptr_not_equal(list_head->next, list_tail);
  munit_assert_ptr_not_equal(list_head->next->curr, list_tail->curr);
  munit_assert_ptr_equal(list_head->next->next, list_tail);
  munit_assert_ptr_equal(list_tail->curr, user_data_or_fixture);
  munit_assert_ptr_equal(list_tail->next, NULL);

  return MUNIT_OK;
}

MunitTest insert_tests[] = {
  {
    "when list head is empty ",
    insert_null_head_test,
    insert_null_head_setup,
    insert_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when list tail is empty ",
    insert_null_tail_test,
    insert_null_tail_setup,
    insert_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when list head and tail are not empty ",
    insert_test,
    insert_setup,
    insert_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite insert_suite = {
  "insert ",
  insert_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
