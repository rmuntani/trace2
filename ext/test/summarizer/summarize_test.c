#include "../munit/munit.h"
#include "event_processor.h"
#include "summarizer.h"

static void
summarize_tear_down(void *fixture) {}

static void*
one_callee_summarize_setup(const MunitParameter params[], void* user_data) {
  classes_list *callees = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *first_callee = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "use";
  use->head_callee = callees;
  use->caller = caller;

  callees->class_use = first_callee;
  callees->next = NULL;

  first_callee->name = "CalleeClass";
  first_callee->method = "callee";

  caller->name = "CallerClass";
  caller->method = "caller";

  return (void*)use;
}

MunitResult
one_callee_summarize_test(const MunitParameter params[], void* use) {
  summarized_use *summarized = summarize((class_use*)use);
  class_methods *caller = (class_methods*)summarized->callers->value,
                *callee = (class_methods*)summarized->callees->value;

  munit_assert_ptr_equal(summarized->callers->next, NULL);
  munit_assert_ptr_equal(summarized->callees->next, NULL);

  munit_assert_string_equal(summarized->use->name, "MyClass");
  munit_assert_string_equal(method_name(summarized->use->methods), "use");

  munit_assert_string_equal(callee->name, "CalleeClass");
  munit_assert_string_equal(method_name(callee->methods), "callee");

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller->methods), "caller");

  return MUNIT_OK;
}

static void*
two_callees_summarize_setup(const MunitParameter params[], void* user_data) {
  classes_list *callees = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *first_callee = malloc(sizeof(class_use)),
            *second_callee = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "use";
  use->head_callee = callees;
  use->caller = caller;

  callees->class_use = first_callee;
  callees->next = malloc(sizeof(classes_list));
  callees->next->class_use = second_callee;
  callees->next->next = NULL;

  first_callee->name = "FirstCalleeClass";
  first_callee->method = "first_callee";

  second_callee->name = "SecondCalleeClass";
  second_callee->method = "second_callee";

  caller->name = "CallerClass";
  caller->method = "caller";

  return (void*)use;
}

MunitResult
two_callees_summarize_test(const MunitParameter params[], void* use) {
  summarized_use *summarized = summarize((class_use*)use);
  class_methods *caller = (class_methods*)summarized->callers->value,
                *first_callee = (class_methods*)summarized->callees->value,
                *second_callee = (class_methods*)summarized->callees->next->value;

  munit_assert_ptr_equal(summarized->callers->next, NULL);
  munit_assert_ptr_not_equal(summarized->callees->next, NULL);
  munit_assert_ptr_equal(summarized->callees->next->next, NULL);

  munit_assert_string_equal(summarized->use->name, "MyClass");
  munit_assert_string_equal(method_name(summarized->use->methods), "use");

  munit_assert_string_equal(first_callee->name, "FirstCalleeClass");
  munit_assert_string_equal(method_name(first_callee->methods), "first_callee");

  munit_assert_string_equal(second_callee->name, "SecondCalleeClass");
  munit_assert_string_equal(method_name(second_callee->methods), "second_callee");

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller->methods), "caller");

  return MUNIT_OK;
}

static void*
same_callee_different_methods_summarize_setup(const MunitParameter params[], void* user_data) {
  classes_list *callees = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *first_callee = malloc(sizeof(class_use)),
            *second_callee = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "use";
  use->head_callee = callees;
  use->caller = caller;

  callees->class_use = first_callee;
  callees->next = malloc(sizeof(classes_list));
  callees->next->class_use = second_callee;
  callees->next->next = NULL;

  first_callee->name = "CalleeClass";
  first_callee->method = "first_callee";

  second_callee->name = "CalleeClass";
  second_callee->method = "second_callee";

  caller->name = "CallerClass";
  caller->method = "caller";

  return (void*)use;
}

MunitResult
same_callee_different_methods_summarize_test(const MunitParameter params[], void* use) {
  summarized_use *summarized = summarize((class_use*)use);
  class_methods *caller = (class_methods*)summarized->callers->value,
                *callee = (class_methods*)summarized->callees->value;

  munit_assert_ptr_equal(summarized->callers->next, NULL);
  munit_assert_ptr_equal(summarized->callees->next, NULL);

  munit_assert_string_equal(summarized->use->name, "MyClass");
  munit_assert_string_equal(method_name(summarized->use->methods), "use");

  munit_assert_string_equal(callee->name, "CalleeClass");
  munit_assert_string_equal(method_name(callee->methods), "first_callee");
  munit_assert_string_equal(method_name(callee->methods->next), "second_callee");

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller->methods), "caller");

  return MUNIT_OK;
}

static void*
repeated_callee_summarize_setup(const MunitParameter params[], void* user_data) {
  classes_list *callees = malloc(sizeof(classes_list));
  class_use *use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *first_callee = malloc(sizeof(class_use)),
            *second_callee = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "use";
  use->head_callee = callees;
  use->caller = caller;

  callees->class_use = first_callee;
  callees->next = malloc(sizeof(classes_list));
  callees->next->class_use = second_callee;
  callees->next->next = NULL;

  first_callee->name = "CalleeClass";
  first_callee->method = "callee";

  second_callee->name = "CalleeClass";
  second_callee->method = "callee";

  caller->name = "CallerClass";
  caller->method = "caller";

  return (void*)use;
}

MunitResult
repeated_callee_summarize_test(const MunitParameter params[], void* use) {
  summarized_use *summarized = summarize((class_use*)use);
  class_methods *caller = (class_methods*)summarized->callers->value,
                *callee = (class_methods*)summarized->callees->value;

  munit_assert_ptr_equal(summarized->callers->next, NULL);
  munit_assert_ptr_equal(summarized->callees->next, NULL);
  munit_assert_ptr_equal(callee->methods->next, NULL);

  munit_assert_string_equal(summarized->use->name, "MyClass");
  munit_assert_string_equal(method_name(summarized->use->methods), "use");

  munit_assert_string_equal(callee->name, "CalleeClass");
  munit_assert_string_equal(method_name(callee->methods), "callee");

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller->methods), "caller");

  return MUNIT_OK;
}

static void*
multiple_callees_summarize_setup(const MunitParameter params[], void* user_data) {
  classes_list *callees, *curr_item;
  class_use *first_use = malloc(sizeof(class_use)),
            *second_use = malloc(sizeof(class_use)),
            *third_use = malloc(sizeof(class_use)),
            *fourth_use = malloc(sizeof(class_use)),
            *fifth_use = malloc(sizeof(class_use)),
            *caller = malloc(sizeof(class_use)),
            *curr_use = malloc(sizeof(class_use));

  first_use->name = "CalleeMyClass";
  first_use->method = "yes";

  second_use->name = "CalleeTheirClass";
  second_use->method = "maybe";

  third_use->name = "CalleeTheirClass";
  third_use->method = "no";

  fourth_use->name = "CalleeMyClass";
  fourth_use->method = "yes";

  fifth_use->name = "CalleeYourClass";
  fifth_use->method = "certainly";

  callees = malloc(sizeof(classes_list));
  callees->class_use = first_use;
  callees->next = malloc(sizeof(classes_list));

  curr_item = callees->next;
  curr_item->class_use = second_use;
  curr_item->next = malloc(sizeof(classes_list));

  curr_item = curr_item->next;
  curr_item->class_use = third_use;
  curr_item->next = malloc(sizeof(classes_list));

  curr_item = curr_item->next;
  curr_item->class_use = fourth_use;
  curr_item->next = malloc(sizeof(classes_list));

  curr_item = curr_item->next;
  curr_item->class_use = fifth_use;
  curr_item->next = NULL;

  caller->name = "CallerClass";
  caller->method = "caller";

  curr_use->name = "CurrentClass";
  curr_use->method = "current";

  curr_use->caller = caller;
  curr_use->head_callee = callees;
  curr_use->tail_callee = NULL; // tail_caller is not used

  return (void*)curr_use;
}

MunitResult
multiple_callees_summarize_test(const MunitParameter params[], void* use) {
  summarized_use *summarized = summarize((class_use*)use);
  class_methods *curr_use = (class_methods*)summarized->use,
                *caller = (class_methods*)summarized->callers->value,
                *first_callee = (class_methods*)summarized->callees->value,
                *second_callee = (class_methods*)summarized->callees->next->value,
                *third_callee = (class_methods*)summarized->callees->next->next->value;

  munit_assert_ptr_equal(summarized->callees->next->next->next, NULL);

  munit_assert_string_equal(curr_use->name, "CurrentClass");
  munit_assert_string_equal(method_name(curr_use->methods), "current");

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller->methods), "caller");

  munit_assert_string_equal(first_callee->name, "CalleeMyClass");
  munit_assert_string_equal(method_name(first_callee->methods), "yes");
  munit_assert_ptr_equal(first_callee->methods->next, NULL);

  munit_assert_string_equal(second_callee->name, "CalleeTheirClass");
  munit_assert_string_equal(method_name(second_callee->methods), "maybe");
  munit_assert_string_equal(method_name(second_callee->methods->next), "no");
  munit_assert_ptr_equal(second_callee->methods->next->next, NULL);

  munit_assert_string_equal(third_callee->name, "CalleeYourClass");
  munit_assert_string_equal(method_name(third_callee->methods), "certainly");
  munit_assert_ptr_equal(third_callee->methods->next, NULL);

  return MUNIT_OK;
}

MunitTest summarize_tests[] = {
  {
    "when there is one callee ",
    one_callee_summarize_test,
    one_callee_summarize_setup,
    summarize_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are two different callees ",
    two_callees_summarize_test,
    two_callees_summarize_setup,
    summarize_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one callee with different methods ",
    same_callee_different_methods_summarize_test,
    same_callee_different_methods_summarize_setup,
    summarize_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when a callee use is repeated ",
    repeated_callee_summarize_test,
    repeated_callee_summarize_setup,
    summarize_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when multiple callees are used ",
    multiple_callees_summarize_test,
    multiple_callees_summarize_setup,
    summarize_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite summarize_suite = {
  "summarize ",
  summarize_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
