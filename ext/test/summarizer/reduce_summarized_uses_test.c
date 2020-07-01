#include "../munit/munit.h"
#include "event_processor.h"
#include "summarizer.h"
#include "helper.h"

static void*
null_list_reduce_summarized_uses_setup(const MunitParameter params[], void* user_data) {
  return (void*)0;
}

MunitResult
null_list_reduce_summarized_uses_test(const MunitParameter params[], void* summarized_uses) {
  list *reduced_summary = reduce_summarized_uses((list*)summarized_uses);

  munit_assert_ptr_equal(reduced_summary, NULL);
  return MUNIT_OK;
}

static void*
one_summarized_use_reduce_setup(const MunitParameter params[], void* user_data) {
  list *summaries;
  char *caller_methods[] = { "caller", NULL },
       *callee_methods[] = { "callee", NULL },
       *use_methods[] = { "use", NULL };
  class_methods *caller = create_fixture_class_methods("CallerClass", caller_methods),
                *callee = create_fixture_class_methods("CalleeClass", callee_methods),
                *use = create_fixture_class_methods("MyClass", use_methods);
  summarized_use *summary = malloc(sizeof(summarized_use));

  summary->callers = wrap_list(caller);
  summary->callees = wrap_list(callee);
  summary->use = use;

  summaries = wrap_list(summary);

  return (void*)summaries;
}

MunitResult
one_summarized_use_reduce_test(const MunitParameter params[], void* summaries) {
  list *reduced_summary = reduce_summarized_uses((list*)summaries);
  summarized_use *only_summary = (summarized_use*)reduced_summary->value;
  class_methods *only_use = only_summary->use,
                *callee = (class_methods*)only_summary->callees->value,
                *caller = (class_methods*)only_summary->callers->value;
  list *use_methods = only_use->methods,
       *callee_methods = callee->methods,
       *caller_methods = caller->methods;

  munit_assert_ptr_not_equal(reduced_summary, NULL);
  munit_assert_ptr_equal(reduced_summary->next, NULL);
  munit_assert_ptr_equal(only_summary->callees->next, NULL);
  munit_assert_ptr_equal(only_summary->callers->next, NULL);

  munit_assert_string_equal(only_use->name, "MyClass");
  munit_assert_string_equal(method_name(use_methods), "use");
  munit_assert_ptr_equal(use_methods->next, NULL);

  munit_assert_string_equal(callee->name, "CalleeClass");
  munit_assert_string_equal(method_name(callee_methods), "callee");
  munit_assert_ptr_equal(callee_methods->next, NULL);

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller_methods), "caller");
  munit_assert_ptr_equal(caller_methods->next, NULL);

  return MUNIT_OK;
}

static void*
two_different_summarized_uses_reduce_setup(const MunitParameter params[], void* user_data) {
  list *summaries;
  char *caller_methods[] = { "caller", NULL },
       *callee_methods[] = { "callee", NULL },
       *use_methods[] = { "use", NULL };
  class_methods *caller = create_fixture_class_methods("CallerClass", caller_methods),
                *callee = create_fixture_class_methods("CalleeClass", callee_methods),
                *first_use = create_fixture_class_methods("FirstClass", use_methods),
                *second_use = create_fixture_class_methods("SecondClass", use_methods);

  summarized_use *first_summary = malloc(sizeof(summarized_use)),
                 *second_summary = malloc(sizeof(summarized_use));

  first_summary->callers = wrap_list(caller);
  first_summary->callees = wrap_list(callee);
  first_summary->use = first_use;

  second_summary->callers = wrap_list(caller);
  second_summary->callees = wrap_list(callee);
  second_summary->use = second_use;

  summaries = wrap_list(first_summary);
  summaries->next = wrap_list(second_summary);

  return (void*)summaries;
}

MunitResult
two_different_summarized_uses_reduce_test(const MunitParameter params[], void* summaries) {
  list *reduced_summary = reduce_summarized_uses((list*)summaries);
  summarized_use *first_summary = (summarized_use*)reduced_summary->value,
                 *second_summary = (summarized_use*)reduced_summary->next->value;
  class_methods *first_use = first_summary->use,
                *second_use = second_summary->use;

  munit_assert_ptr_equal(reduced_summary->next->next, NULL);

  munit_assert_string_equal(first_use->name, "FirstClass");
  munit_assert_string_equal(second_use->name, "SecondClass");

  return MUNIT_OK;
}

static void*
two_repeated_summarized_uses_reduce_setup(const MunitParameter params[], void* user_data) {
  list *summaries;
  char *caller_methods[] = { "caller", NULL },
       *callee_methods[] = { "callee", NULL },
       *first_use_methods[] = { "first_use", "use", NULL },
       *second_use_methods[] = { "use", "second_use", NULL };
  class_methods *caller = create_fixture_class_methods("CallerClass", caller_methods),
                *callee = create_fixture_class_methods("CalleeClass", callee_methods),
                *first_use = create_fixture_class_methods("MyClass", first_use_methods),
                *second_use = create_fixture_class_methods("MyClass", second_use_methods);

  summarized_use *first_summary = malloc(sizeof(summarized_use)),
                 *second_summary = malloc(sizeof(summarized_use));

  first_summary->callers = wrap_list(caller);
  first_summary->callees = wrap_list(callee);
  first_summary->use = first_use;

  second_summary->callers = wrap_list(caller);
  second_summary->callees = wrap_list(callee);
  second_summary->use = second_use;

  summaries = wrap_list(first_summary);
  summaries->next = wrap_list(second_summary);

  return (void*)summaries;
}

MunitResult
two_repeated_summarized_uses_reduce_test(const MunitParameter params[], void* summaries) {
  list *reduced_summary = reduce_summarized_uses((list*)summaries),
       *methods;
  summarized_use *only_summary = (summarized_use*)reduced_summary->value;
  class_methods *only_use = only_summary->use;

  methods = only_use->methods;

  munit_assert_ptr_equal(reduced_summary->next, NULL);

  munit_assert_string_equal(only_use->name, "MyClass");

  munit_assert_string_equal(method_name(methods), "first_use");
  munit_assert_string_equal(method_name(methods->next), "use");
  munit_assert_string_equal(method_name(methods->next->next), "second_use");

  return MUNIT_OK;
}

static void*
same_use_different_callees_reduce_setup(const MunitParameter params[], void* user_data) {
  list *summaries;
  char *caller_methods[] = { "caller", NULL },
       *first_callee_methods[] = { "first_callee", NULL },
       *second_callee_methods[] = { "second_callee", NULL },
       *use_methods[] = { "use", NULL };

  class_methods *caller = create_fixture_class_methods("CallerClass", caller_methods),
                *first_callee = create_fixture_class_methods("FirstCalleeClass", first_callee_methods),
                *second_callee = create_fixture_class_methods("SecondCalleeClass", second_callee_methods),
                *use = create_fixture_class_methods("MyClass", use_methods);

  summarized_use *first_summary = malloc(sizeof(summarized_use)),
                 *second_summary = malloc(sizeof(summarized_use));

  first_summary->callers = wrap_list(caller);
  first_summary->callees = wrap_list(first_callee);
  first_summary->use = use;

  second_summary->callers = wrap_list(caller);
  second_summary->callees = wrap_list(second_callee);
  second_summary->use = use;

  summaries = wrap_list(first_summary);
  summaries->next = wrap_list(second_summary);

  return (void*)summaries;
}

MunitResult
same_use_different_callees_reduce_test(const MunitParameter params[], void* summaries) {
  list *reduced_summary = reduce_summarized_uses((list*)summaries);
  summarized_use *only_summary = (summarized_use*)reduced_summary->value;
  class_methods *only_use = only_summary->use,
                *first_callee = (class_methods*)only_summary->callees->value,
                *second_callee = (class_methods*)only_summary->callees->next->value,
                *caller = (class_methods*)only_summary->callers->value;
  list *use_methods = only_use->methods,
       *first_callee_methods = first_callee->methods,
       *second_callee_methods = second_callee->methods,
       *caller_methods = caller->methods;

  munit_assert_ptr_not_equal(reduced_summary, NULL);
  munit_assert_ptr_equal(reduced_summary->next, NULL);
  munit_assert_ptr_equal(only_summary->callees->next->next, NULL);
  munit_assert_ptr_equal(only_summary->callers->next, NULL);

  munit_assert_string_equal(only_use->name, "MyClass");
  munit_assert_string_equal(method_name(use_methods), "use");
  munit_assert_ptr_equal(use_methods->next, NULL);

  munit_assert_string_equal(first_callee->name, "FirstCalleeClass");
  munit_assert_string_equal(method_name(first_callee_methods), "first_callee");
  munit_assert_ptr_equal(first_callee_methods->next, NULL);

  munit_assert_string_equal(second_callee->name, "SecondCalleeClass");
  munit_assert_string_equal(method_name(second_callee_methods), "second_callee");
  munit_assert_ptr_equal(second_callee_methods->next, NULL);

  munit_assert_string_equal(caller->name, "CallerClass");
  munit_assert_string_equal(method_name(caller_methods), "caller");
  munit_assert_ptr_equal(caller_methods->next, NULL);

  return MUNIT_OK;
}

static void*
same_use_different_callers_reduce_setup(const MunitParameter params[], void* user_data) {
  list *summaries;
  char *callee_methods[] = { "callee", NULL },
       *first_caller_methods[] = { "first_caller", NULL },
       *second_caller_methods[] = { "second_caller", NULL },
       *use_methods[] = { "use", NULL };

  class_methods *callee = create_fixture_class_methods("CalleeClass", callee_methods),
                *first_caller = create_fixture_class_methods("FirstCallerClass", first_caller_methods),
                *second_caller = create_fixture_class_methods("SecondCallerClass", second_caller_methods),
                *use = create_fixture_class_methods("MyClass", use_methods);

  summarized_use *first_summary = malloc(sizeof(summarized_use)),
                 *second_summary = malloc(sizeof(summarized_use));

  first_summary->callers = wrap_list(first_caller);
  first_summary->callees = wrap_list(callee);
  first_summary->use = use;

  second_summary->callers = wrap_list(second_caller);
  second_summary->callees = wrap_list(callee);
  second_summary->use = use;

  summaries = wrap_list(first_summary);
  summaries->next = wrap_list(second_summary);

  return (void*)summaries;
}

MunitResult
same_use_different_callers_reduce_test(const MunitParameter params[], void* summaries) {
  list *reduced_summary = reduce_summarized_uses((list*)summaries);
  summarized_use *only_summary = (summarized_use*)reduced_summary->value;
  class_methods *only_use = only_summary->use,
                *first_caller = (class_methods*)only_summary->callers->value,
                *second_caller = (class_methods*)only_summary->callers->next->value,
                *callee = (class_methods*)only_summary->callees->value;
  list *use_methods = only_use->methods,
       *first_caller_methods = first_caller->methods,
       *second_caller_methods = second_caller->methods,
       *callee_methods = callee->methods;

  munit_assert_ptr_not_equal(reduced_summary, NULL);
  munit_assert_ptr_equal(reduced_summary->next, NULL);
  munit_assert_ptr_equal(only_summary->callers->next->next, NULL);
  munit_assert_ptr_equal(only_summary->callees->next, NULL);

  munit_assert_string_equal(only_use->name, "MyClass");
  munit_assert_string_equal(method_name(use_methods), "use");
  munit_assert_ptr_equal(use_methods->next, NULL);

  munit_assert_string_equal(first_caller->name, "FirstCallerClass");
  munit_assert_string_equal(method_name(first_caller_methods), "first_caller");
  munit_assert_ptr_equal(first_caller_methods->next, NULL);

  munit_assert_string_equal(second_caller->name, "SecondCallerClass");
  munit_assert_string_equal(method_name(second_caller_methods), "second_caller");
  munit_assert_ptr_equal(second_caller_methods->next, NULL);

  munit_assert_string_equal(callee->name, "CalleeClass");
  munit_assert_string_equal(method_name(callee_methods), "callee");
  munit_assert_ptr_equal(callee_methods->next, NULL);

  return MUNIT_OK;
}

MunitTest reduce_summarized_uses_tests[] = {
  {
    "when summaries are NULL",
    null_list_reduce_summarized_uses_test,
    null_list_reduce_summarized_uses_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one summarized_use ",
    one_summarized_use_reduce_test,
    one_summarized_use_reduce_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there there are two different summarized_uses ",
    two_different_summarized_uses_reduce_test,
    two_different_summarized_uses_reduce_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there there are two summarized_uses with the same class ",
    two_repeated_summarized_uses_reduce_test,
    two_repeated_summarized_uses_reduce_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one use with different callees ",
    same_use_different_callees_reduce_test,
    same_use_different_callees_reduce_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one use with different callers ",
    same_use_different_callers_reduce_test,
    same_use_different_callers_reduce_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite reduce_summarized_uses_suite = {
  "reduce_summarized_uses ",
  reduce_summarized_uses_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
