#include "../munit/munit.h"
#include "event_processor.h"
#include "summarizer.h"

static void
reduce_uses_list_tear_down(void *fixture) {}

static void*
single_use_list_reduce_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses = malloc(sizeof(classes_list));
  class_use *curr_use = malloc(sizeof(class_use));

  curr_use->name = "MyClass";
  curr_use->method = "yes";

  uses->class_use = curr_use;
  uses->next = NULL;

  return (void*)uses;
}

MunitResult
single_use_list_reduce_test(const MunitParameter params[], void* uses) {
  summarized_list *summary = reduce_uses_list((classes_list*)uses);

  munit_assert_ptr_not_equal(summary, NULL);
  munit_assert_ptr_equal(summary->next, NULL);
  munit_assert_ptr_equal(summary->methods->next, NULL);
  munit_assert_ptr_not_equal(summary->methods, NULL);

  munit_assert_string_equal(summary->name, "MyClass");
  munit_assert_string_equal(summary->methods->name, "yes");

  return MUNIT_OK;
}

static void*
two_different_uses_list_reduce_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses;
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use));

  first_use->name = "MyClass";
  first_use->method = "yes";

  second_use->name = "YourClass";
  second_use->method = "no";

  uses = malloc(sizeof(classes_list));
  uses->class_use = first_use;

  uses->next = malloc(sizeof(classes_list));
  uses->next->class_use = second_use;

  uses->next->next = NULL;

  return (void*)uses;
}

MunitResult
two_different_uses_list_reduce_test(const MunitParameter params[], void* uses) {
  summarized_list *summary = reduce_uses_list((classes_list*)uses);

  munit_assert_ptr_not_equal(summary, NULL);
  munit_assert_ptr_not_equal(summary->next, NULL);
  munit_assert_ptr_equal(summary->next->next, NULL);

  munit_assert_string_equal(summary->name, "MyClass");
  munit_assert_ptr_not_equal(summary->methods, NULL);
  munit_assert_string_equal(summary->methods->name, "yes");
  munit_assert_ptr_equal(summary->methods->next, NULL);

  munit_assert_string_equal(summary->next->name, "YourClass");
  munit_assert_ptr_not_equal(summary->next->methods, NULL);
  munit_assert_string_equal(summary->next->methods->name, "no");
  munit_assert_ptr_equal(summary->next->methods->next, NULL);

  return MUNIT_OK;
}

static void*
same_class_different_methods_list_reduce_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses;
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use));

  first_use->name = "MyClass";
  first_use->method = "yes";

  second_use->name = "MyClass";
  second_use->method = "no";

  uses = malloc(sizeof(classes_list));
  uses->class_use = first_use;

  uses->next = malloc(sizeof(classes_list));
  uses->next->class_use = second_use;

  uses->next->next = NULL;

  return (void*)uses;
}

MunitResult
same_class_different_methods_list_reduce_test(const MunitParameter params[], void* uses) {
  summarized_list *summary = reduce_uses_list((classes_list*)uses);

  munit_assert_ptr_not_equal(summary, NULL);
  munit_assert_ptr_equal(summary->next, NULL);

  munit_assert_string_equal(summary->name, "MyClass");
  munit_assert_ptr_not_equal(summary->methods, NULL);
  munit_assert_ptr_not_equal(summary->methods->next, NULL);

  munit_assert_string_equal(summary->methods->name, "yes");
  munit_assert_ptr_equal(summary->methods->next->name, "no");

  return MUNIT_OK;
}

static void*
repeated_uses_list_reduce_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses;
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use));

  first_use->name = "MyClass";
  first_use->method = "yes";

  second_use->name = "MyClass";
  second_use->method = "yes";

  uses = malloc(sizeof(classes_list));
  uses->class_use = first_use;

  uses->next = malloc(sizeof(classes_list));
  uses->next->class_use = second_use;

  uses->next->next = NULL;

  return (void*)uses;
}

MunitResult
repeated_uses_list_reduce_test(const MunitParameter params[], void* uses) {
  summarized_list *summary = reduce_uses_list((classes_list*)uses);

  munit_assert_ptr_not_equal(summary, NULL);
  munit_assert_ptr_equal(summary->next, NULL);
  munit_assert_string_equal(summary->name, "MyClass");

  munit_assert_ptr_not_equal(summary->methods, NULL);
  munit_assert_string_equal(summary->methods->name, "yes");
  munit_assert_ptr_equal(summary->methods->next, NULL);

  return MUNIT_OK;
}

static void*
multiple_uses_list_reduce_setup(const MunitParameter params[], void* user_data) {
  classes_list *uses, *curr_use;
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use)),
            *third_use = malloc(sizeof(class_use)),
            *fourth_use = malloc(sizeof(class_use)),
            *fifth_use = malloc(sizeof(class_use));

  first_use->name = "MyClass";
  first_use->method = "yes";

  second_use->name = "TheirClass";
  second_use->method = "maybe";

  third_use->name = "TheirClass";
  third_use->method = "no";

  fourth_use->name = "MyClass";
  fourth_use->method = "yes";

  fifth_use->name = "YourClass";
  fifth_use->method = "certainly";
  uses = malloc(sizeof(classes_list));
  uses->class_use = first_use;
  uses->next = malloc(sizeof(classes_list));

  curr_use = uses->next;
  curr_use->class_use = second_use;
  curr_use->next = malloc(sizeof(classes_list));

  curr_use = curr_use->next;
  curr_use->class_use = third_use;
  curr_use->next = malloc(sizeof(classes_list));

  curr_use = curr_use->next;
  curr_use->class_use = fourth_use;
  curr_use->next = malloc(sizeof(classes_list));

  curr_use = curr_use->next;
  curr_use->class_use = fifth_use;
  curr_use->next = NULL;

  return (void*)uses;
}

MunitResult
multiple_uses_list_reduce_test(const MunitParameter params[], void* uses) {
  summarized_list *first_summary = reduce_uses_list((classes_list*)uses),
                  *second_summary = first_summary->next,
                  *third_summary = second_summary->next;

  munit_assert_ptr_equal(third_summary->next, NULL);

  munit_assert_string_equal(first_summary->name, "MyClass");
  munit_assert_string_equal(first_summary->methods->name, "yes");
  munit_assert_ptr_equal(first_summary->methods->next, NULL);

  munit_assert_string_equal(second_summary->name, "TheirClass");
  munit_assert_string_equal(second_summary->methods->name, "maybe");
  munit_assert_string_equal(second_summary->methods->next->name, "no");
  munit_assert_ptr_equal(second_summary->methods->next->next, NULL);

  munit_assert_string_equal(third_summary->name, "YourClass");
  munit_assert_string_equal(third_summary->methods->name, "certainly");
  munit_assert_ptr_equal(third_summary->methods->next, NULL);

  return MUNIT_OK;
}

MunitTest reduce_uses_list_tests[] = {
  {
    "when there is only one class use ",
    single_use_list_reduce_test,
    single_use_list_reduce_setup,
    reduce_uses_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are two different classes uses",
    two_different_uses_list_reduce_test,
    two_different_uses_list_reduce_setup,
    reduce_uses_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one class with different methods",
    same_class_different_methods_list_reduce_test,
    same_class_different_methods_list_reduce_setup,
    reduce_uses_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when a class use is repeated",
    repeated_uses_list_reduce_test,
    repeated_uses_list_reduce_setup,
    reduce_uses_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are multiple classes uses",
    multiple_uses_list_reduce_test,
    multiple_uses_list_reduce_setup,
    reduce_uses_list_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite reduce_uses_list_suite = {
  "reduce_uses_list ",
  reduce_uses_list_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
