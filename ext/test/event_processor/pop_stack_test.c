#define MUNIT_ENABLE_ASSERT_ALIASES
#include "../munit/munit.h"
#include "event_processor.h"

extern struct classes_stack *top;
extern struct classes_list *list_head;
extern struct classes_list *list_tail;

void clear_list() {
  struct classes_list *free_node;

  while(list_head) {
    free_node = list_head;     
    list_head = list_head->next;
    free(free_node);
  }
  free(list_head);
  free(list_tail);

  list_head = NULL;
  list_tail = NULL;
}

void clear_stack() {
  struct classes_stack *free_top;

  while (top) {
    free_top = top;
    top = top->prev;
    free(free_top);
  }
  free(top);

  top = NULL;
}

static void* 
pop_stack_setup_empty_head(const MunitParameter params[], void* user_data) {
  list_head = NULL;
  list_tail = NULL;

  top = malloc(sizeof(struct classes_stack));
}

static void* 
pop_stack_setup_empty_tail(const MunitParameter params[], void* user_data) {
  list_tail = NULL;

  top = malloc(sizeof(struct classes_stack));

  list_head = malloc(sizeof(struct classes_list));
  list_head->curr = malloc(sizeof(struct classes_stack));
  list_head->next = NULL;
}

static void* 
pop_stack_setup_list(const MunitParameter params[], void* user_data) {
  top = malloc(sizeof(struct classes_stack));
  list_head = malloc(sizeof(struct classes_list));
  list_tail =  malloc(sizeof(struct classes_list));

  list_tail->curr = malloc(sizeof(struct classes_stack));
  list_tail->next = NULL;

  list_head->curr = malloc(sizeof(struct classes_stack));
  list_head->next = list_tail;
}

static void
pop_stack_tear_down(void *fixture) {
  clear_stack();
  clear_list();
}

MunitResult 
pop_stack_empty_head(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;

  pop_stack();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(original_top, list_head->curr);
  munit_assert_ptr_equal(list_head->next, NULL);
  munit_assert_ptr_equal(list_tail, NULL);
}

MunitResult 
pop_stack_empty_tail(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;

  pop_stack();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_equal(list_head->next, list_tail);
  munit_assert_ptr_equal(list_tail->curr, original_top);
  munit_assert_ptr_equal(list_tail->next, NULL);
}

MunitResult 
pop_stack_list(const MunitParameter params[], void* user_data_or_fixture) {
  struct classes_stack *original_top = top;
  struct classes_list *original_tail = list_tail;

  pop_stack();

  munit_assert_ptr_equal(top, NULL);
  munit_assert_ptr_not_equal(list_head->next, list_tail);
  munit_assert_ptr_not_equal(original_tail, list_tail);
  munit_assert_ptr_equal(list_tail->curr, original_top);
  munit_assert_ptr_equal(list_tail->next, NULL);
}

MunitTest pop_stack_tests[] = {
  {
    " when classes list head and tail exists",
    pop_stack_list,
    pop_stack_setup_list,
    pop_stack_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
    " when classes list head is empty",
    pop_stack_empty_head,
    pop_stack_setup_empty_head,
    pop_stack_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    " when classes list tail is not empty",
    pop_stack_empty_tail,
    pop_stack_setup_empty_tail,
    pop_stack_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite pop_stack_suite = {
  "pop_stack",
  pop_stack_tests,
  NULL, 
  1,
  MUNIT_SUITE_OPTION_NONE
};
