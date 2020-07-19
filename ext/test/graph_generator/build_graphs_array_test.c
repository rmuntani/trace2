#include <string.h>
#include "../munit/munit.h"
#include "event_processor.h"
#include "graph_generator.h"

// count_ocurrences is used as a support function to
// assert that a string was generated by the build_graphs_array
// function
int count_ocurrences(char** arry, char* str) {
  int count = 0;
  while(*arry != NULL) {
    if(strcmp(str, *arry) == 0) count++;
    arry++;
  }

  return count;
}

static void*
one_use_build_graphs_array_setup(const MunitParameter params[], void* user_data) {
  classes_list *head = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use));

  use->name = "Use";
  use->caller = NULL;
  use->head_callee = NULL;

  head->class_use = use;
  head->next = NULL;

  return (void*)head;
}

MunitResult
one_use_build_graphs_array_test(const MunitParameter params[], void* classes_list_head) {
  classes_list *head = (classes_list*)classes_list_head;
  char** graphs_array = build_graphs_array(head, 10);

  munit_assert_ptr_equal(*graphs_array, NULL);

  return MUNIT_OK;
}

static void*
one_use_with_relationships_build_graphs_array_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses_list = malloc(sizeof(classes_list)),
               *head = malloc(sizeof(classes_list)),
               *tail = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *first_callee = malloc(sizeof(class_use)),
            *second_callee = malloc(sizeof(class_use));

  use->name = "Use";
  caller->name = "Caller";
  first_callee->name = "FirstCallee";
  second_callee->name = "SecondCallee";

  head->class_use = first_callee;
  head->next = tail;
  tail->class_use = second_callee;
  tail->next = NULL;

  use->caller = caller;
  use->head_callee = head;
  use->tail_callee = tail;

  uses_list->class_use = use;
  uses_list->next = NULL;

  return (void*)uses_list;
}

MunitResult
one_use_with_relationships_build_graphs_array_test(const MunitParameter params[], void* classes_list_head) {
  classes_list *head = (classes_list*)classes_list_head;
  char** graphs_array = build_graphs_array(head, 10);

  munit_assert_int(count_ocurrences(graphs_array, "Caller -> Use"), ==, 1);
  munit_assert_int(count_ocurrences(graphs_array, "Use -> FirstCallee"), ==, 1);
  munit_assert_int(count_ocurrences(graphs_array, "Use -> SecondCallee"), ==, 1);

  munit_assert_ptr_equal(*(graphs_array + 3), NULL);

  return MUNIT_OK;
}

static void*
repeated_relationships_build_graphs_array_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses_list = malloc(sizeof(classes_list)),
               *second_node = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use));

  use->name = "Use";
  use->caller = caller;
  caller->name = "Caller";

  uses_list->class_use = use;
  second_node->class_use = use;

  uses_list->next = second_node;
  second_node->next = NULL;

  return (void*)uses_list;
}

MunitResult
repeated_relationships_build_graphs_array_test(const MunitParameter params[], void* classes_list_head) {
  classes_list *head = (classes_list*)classes_list_head;
  char** graphs_array = build_graphs_array(head, 10);

  munit_assert_string_equal(*graphs_array, "Caller -> Use");
  munit_assert_ptr_equal(*(graphs_array + 1), NULL);

  return MUNIT_OK;
}

static void*
multiple_uses_build_graphs_array_setup(const MunitParameter params[], void* user_data) {
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use)),
            *third_use = malloc(sizeof(class_use)),
            *extra_use = malloc(sizeof(class_use));
  classes_list *uses_list = malloc(sizeof(classes_list)),
               *first_callees = malloc(sizeof(classes_list)),
               *second_callees = malloc(sizeof(classes_list)),
               *third_callees = malloc(sizeof(classes_list));

  // Set classes uses without callees
  first_use->name = "FirstUse";
  first_use->caller = NULL;

  second_use->name = "SecondUse";
  second_use->caller = first_use;

  third_use->name = "ThirdUse";
  third_use->caller = second_use;

  extra_use->name = "Extra";
  extra_use->caller = second_use;

  uses_list->class_use = first_use;

  // Set classes uses with callees. Callees' tails are ignored
  first_use->head_callee = malloc(sizeof(classes_list));
  first_use->head_callee->class_use = second_use;
  first_use->head_callee->next = NULL;

  second_use->head_callee = malloc(sizeof(classes_list));
  second_use->head_callee->class_use = third_use;

  second_use->head_callee->next = malloc(sizeof(classes_list));
  second_use->head_callee->next->class_use = extra_use;

  second_use->head_callee->next->next = malloc(sizeof(classes_list));
  second_use->head_callee->next->next->class_use = second_use;

  second_use->head_callee->next->next->next = NULL;

  third_use->head_callee = NULL;

  // Set final list up
  uses_list->next = malloc(sizeof(classes_list));
  uses_list->next->class_use = second_use;

  uses_list->next->next = malloc(sizeof(classes_list));
  uses_list->next->next->class_use = third_use;

  uses_list->next->next->next = NULL;

  return (void*)uses_list;
}

MunitResult
multiple_uses_build_graphs_array_test(const MunitParameter params[], void* classes_list_head) {
  classes_list *head = (classes_list*)classes_list_head;
  char** graphs_array = build_graphs_array(head, 10);

  munit_assert_int(count_ocurrences(graphs_array, "FirstUse -> SecondUse"), ==, 1);
  munit_assert_int(count_ocurrences(graphs_array, "SecondUse -> ThirdUse"), ==, 1);
  munit_assert_int(count_ocurrences(graphs_array, "SecondUse -> Extra"), ==, 1);
  munit_assert_int(count_ocurrences(graphs_array, "SecondUse -> SecondUse"), ==, 1);

  munit_assert_ptr_equal(*(graphs_array + 4), NULL);

  return MUNIT_OK;
}

MunitTest build_graphs_array_tests[] = {
  {
    "when ther is one use with no caller and callees",
    one_use_build_graphs_array_test,
    one_use_build_graphs_array_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one use with caller and callees",
    one_use_with_relationships_build_graphs_array_test,
    one_use_with_relationships_build_graphs_array_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one use with repeated relationships",
    repeated_relationships_build_graphs_array_test,
    repeated_relationships_build_graphs_array_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one use with repeated relationships",
    repeated_relationships_build_graphs_array_test,
    repeated_relationships_build_graphs_array_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are multiple classes uses",
    multiple_uses_build_graphs_array_test,
    multiple_uses_build_graphs_array_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite build_graphs_array_suite = {
  "build_graphs_array ",
  build_graphs_array_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};