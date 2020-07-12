#include "../munit/munit.h"
#include "event_processor.h"
#include "graph_generator.h"

static void*
no_caller_graph_strings_setup(const MunitParameter params[], void* user_data) {
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->caller = NULL;

  return use;
}

MunitResult
no_caller_graph_strings_test(const MunitParameter params[], void* class_use_setup) {
  class_use *use = (class_use*)class_use_setup;
  char** uses_keys = graph_strings(use);

  munit_assert_ptr_equal(*uses_keys, NULL);

  return MUNIT_OK;
}

static void*
one_caller_graph_strings_setup(const MunitParameter params[], void* user_data) {
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use));

  use->name = "MyClass";
  caller->name = "TheirClass";

  use->caller = caller;
  use->head_callee = NULL;

  return use;
}

MunitResult
one_caller_graph_strings_test(const MunitParameter params[], void* class_use_setup) {
  class_use *use = (class_use*)class_use_setup;
  char** uses_keys = graph_strings(use);

  munit_assert_string_equal(*uses_keys, "TheirClass -> MyClass");

  munit_assert_ptr_equal(*(uses_keys + 1), NULL);

  return MUNIT_OK;
}

static void*
many_callees_graph_strings_setup(const MunitParameter params[], void* user_data) {
  class_use *use = malloc(sizeof(class_use)),
            *first_callee_use = malloc(sizeof(class_use)),
            *second_callee_use = malloc(sizeof(class_use)),
            *third_callee_use = malloc(sizeof(class_use));

  classes_list *first_item = malloc(sizeof(classes_list)),
               *second_item = malloc(sizeof(classes_list)),
               *third_item = malloc(sizeof(classes_list));

  use->name = "MyClass";

  first_callee_use->name = "FirstCallee";
  second_callee_use->name = "SecondCallee";
  third_callee_use->name = "ThirdCallee";

  first_item->class_use = first_callee_use;
  second_item->class_use = second_callee_use;
  third_item->class_use = third_callee_use;

  first_item->next = second_item;
  second_item->next = third_item;
  third_item->next = NULL;

  use->caller = NULL;

  use->head_callee = first_item;

  return use;
}

MunitResult
many_callees_graph_strings_test(const MunitParameter params[], void* class_use_setup) {
  class_use *use = (class_use*)class_use_setup;
  char** uses_keys = graph_strings(use);

  munit_assert_string_equal(*uses_keys, "MyClass -> FirstCallee");
  munit_assert_string_equal(*(uses_keys + 1), "MyClass -> SecondCallee");
  munit_assert_string_equal(*(uses_keys + 2), "MyClass -> ThirdCallee");

  munit_assert_ptr_equal(*(uses_keys + 3), NULL);

  return MUNIT_OK;
}

static void*
use_with_caller_and_callees_graph_strings_setup(const MunitParameter params[], void* user_data) {
  class_use *use = malloc(sizeof(class_use)),
            *first_callee_use = malloc(sizeof(class_use)),
            *second_callee_use = malloc(sizeof(class_use)),
            *third_callee_use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use));

  classes_list *first_item = malloc(sizeof(classes_list)),
               *second_item = malloc(sizeof(classes_list)),
               *third_item = malloc(sizeof(classes_list));

  use->name = "MyClass";
  caller->name = "Caller";

  first_callee_use->name = "FirstCallee";
  second_callee_use->name = "SecondCallee";
  third_callee_use->name = "ThirdCallee";

  first_item->class_use = first_callee_use;
  second_item->class_use = second_callee_use;
  third_item->class_use = third_callee_use;

  first_item->next = second_item;
  second_item->next = third_item;
  third_item->next = NULL;

  use->caller = caller;

  use->head_callee = first_item;

  return use;
}

MunitResult
use_with_caller_and_callees_graph_strings_test(const MunitParameter params[], void* class_use_setup) {
  class_use *use = (class_use*)class_use_setup;
  char** uses_keys = graph_strings(use);

  munit_assert_string_equal(*uses_keys, "Caller -> MyClass");
  munit_assert_string_equal(*(uses_keys + 1), "MyClass -> FirstCallee");
  munit_assert_string_equal(*(uses_keys + 2), "MyClass -> SecondCallee");
  munit_assert_string_equal(*(uses_keys + 3), "MyClass -> ThirdCallee");

  munit_assert_ptr_equal(*(uses_keys + 4), NULL);

  return MUNIT_OK;
}

MunitTest graph_strings_tests[] = {
  {
    "when a use has no caller or callees ",
    no_caller_graph_strings_test,
    no_caller_graph_strings_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when a use has a caller and no callees ",
    one_caller_graph_strings_test,
    one_caller_graph_strings_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when use has many callees and no caller ",
    many_callees_graph_strings_test,
    many_callees_graph_strings_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when use has callees and a caller ",
    use_with_caller_and_callees_graph_strings_test,
    use_with_caller_and_callees_graph_strings_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite graph_strings_suite = {
  "graph_strings ",
  graph_strings_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
