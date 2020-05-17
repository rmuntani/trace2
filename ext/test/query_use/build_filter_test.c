#include <string.h>
#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

static void*
simple_filter_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*10);

  simple_filter[0] = "1";
  simple_filter[1] = "1";
  simple_filter[2] = "1";
  simple_filter[3] = "1";
  simple_filter[4] = "validate_name";
  simple_filter[5] = "1";
  simple_filter[6] = "MyClass";
  simple_filter[7] = "allow";
  simple_filter[8] = "filter";
  simple_filter[9] = NULL;

  return (void*)simple_filter;
}

MunitResult
simple_filter_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *actions;
  validation **validations;

  filters = build_filters((char**)filter_fixture);
  actions = filters->actions;
  validations = actions->validations;

  munit_assert_int(filters->num_actions, ==, 1);
  munit_assert_int(actions->num_validations, ==, 1);
  munit_assert_int(actions->type, ==, ALLOW);
  munit_assert_string_equal("MyClass", *((char**)(*validations)->values));
  munit_assert_ptr_equal((*validations)->function, valid_name);

  return MUNIT_OK;
}

static void*
simple_filter_int_value_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*10);

  simple_filter[0] = "1";
  simple_filter[1] = "1";
  simple_filter[2] = "1";
  simple_filter[3] = "1";
  simple_filter[4] = "validate_lineno";
  simple_filter[5] = "1";
  simple_filter[6] = "28";
  simple_filter[7] = "allow";
  simple_filter[8] = "filter";
  simple_filter[9] = NULL;

  return (void*)simple_filter;
}

MunitResult
simple_filter_int_value_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *actions;
  validation **validations;

  filters = build_filters((char**)filter_fixture);
  actions = filters->actions;
  validations = actions->validations;

  munit_assert_int(filters->num_actions, ==, 1);
  munit_assert_int(actions->num_validations, ==, 1);
  munit_assert_int(actions->type, ==, ALLOW);
  munit_assert_int(28, ==, *((int*)(*validations)->values));
  munit_assert_ptr_equal((*validations)->function, valid_lineno);

  return MUNIT_OK;
}

static void*
single_filter_multi_value_validation_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*11);

  simple_filter[0] = "1";
  simple_filter[1] = "1";
  simple_filter[2] = "1";
  simple_filter[3] = "1";
  simple_filter[4] = "validate_name";
  simple_filter[5] = "2";
  simple_filter[6] = "MyClass";
  simple_filter[7] = "YourClass";
  simple_filter[8] = "allow";
  simple_filter[9] = "filter";
  simple_filter[10] = NULL;

  return (void*)simple_filter;
}

MunitResult
single_filter_multi_value_validation_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *actions;
  validation **validations;

  filters = build_filters((char**)filter_fixture);
  actions = filters->actions;
  validations = actions->validations;

  munit_assert_int(filters->num_actions, ==, 1);
  munit_assert_int(actions->num_validations, ==, 1);
  munit_assert_int(actions->type, ==, ALLOW);
  munit_assert_string_equal("MyClass", *((char**)(*validations)->values));
  munit_assert_string_equal("YourClass", *(((char**)(*validations)->values) + 1));
  munit_assert_ptr_equal((*validations)->function, valid_name);

  return MUNIT_OK;
}

static void*
single_filter_multiple_validations_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*11);

  simple_filter[0] =  "1";
  simple_filter[1] =  "1";
  simple_filter[2] =  "1";
  simple_filter[3] =  "2";
  simple_filter[4] =  "validate_name";
  simple_filter[5] =  "1";
  simple_filter[6] =  "MyClass";
  simple_filter[7] =  "validate_method";
  simple_filter[8] =  "1";
  simple_filter[9] =  "yes";
  simple_filter[10] =  "allow";
  simple_filter[11] =  "filter";
  simple_filter[12] =  "filter";

  return (void*)simple_filter;
}

MunitResult
single_filter_multiple_validations_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *actions;
  validation **validations;

  filters = build_filters((char**)filter_fixture);
  actions = filters->actions;
  validations = actions->validations;

  munit_assert_int(filters->num_actions, ==, 1);
  munit_assert_int(actions->num_validations, ==, 1);
  munit_assert_int(actions->type, ==, ALLOW);
  munit_assert_string_equal("MyClass", *((char**)(*validations)->values));
  munit_assert_string_equal("yes", *((char**)(*validations + 1)->values));
  munit_assert_ptr_equal((*validations)->function, valid_name);
  munit_assert_ptr_equal((*validations+1)->function, valid_method);

  return MUNIT_OK;
}

static void*
single_filter_parallel_validations_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*11);

  simple_filter[0] = "1";
  simple_filter[1] = "1";
  simple_filter[2] = "2";
  simple_filter[3] = "1";
  simple_filter[4] = "validate_name";
  simple_filter[5] = "1";
  simple_filter[6] = "MyClass";
  simple_filter[7] = "1";
  simple_filter[8] = "validate_method";
  simple_filter[9] = "1";
  simple_filter[10] = "yes";
  simple_filter[11] = "allow";
  simple_filter[12] = "filter";
  simple_filter[13] = NULL;

  return (void*)simple_filter;
}

MunitResult
single_filter_parallel_validations_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *actions;
  validation **validations;

  filters = build_filters((char**)filter_fixture);
  actions = filters->actions;
  validations = actions->validations;

  munit_assert_int(filters->num_actions, ==, 1);
  munit_assert_int(actions->num_validations, ==, 2);
  munit_assert_int(actions->type, ==, ALLOW);
  munit_assert_string_equal("MyClass", *((char**)(*validations)->values));
  munit_assert_string_equal("yes", *((char**)(*(validations + 1))->values));
  munit_assert_ptr_equal((*validations)->function, valid_name);
  munit_assert_ptr_equal((*(validations + 1))->function, valid_method);

  return MUNIT_OK;
}

static void*
single_filter_multiple_actions_build_setup(const MunitParameter params[], void* user_data) {
  char **simple_filter = malloc(sizeof(char*)*16);

  simple_filter[0] = "1";
  simple_filter[1] = "2";
  simple_filter[2] = "1";
  simple_filter[3] = "1";
  simple_filter[4] = "validate_name";
  simple_filter[5] = "1";
  simple_filter[6] = "MyClass";
  simple_filter[7] = "allow";
  simple_filter[8] = "1";
  simple_filter[9] = "1";
  simple_filter[10] = "validate_method";
  simple_filter[11] = "1";
  simple_filter[12] = "no";
  simple_filter[13] = "reject";
  simple_filter[14] = "filter";
  simple_filter[15] = NULL;

  return (void*)simple_filter;
}

MunitResult
single_filter_multiple_actions_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *filters;
  action *first_action, *second_action;
  validation **first_validations, **second_validations;

  filters = build_filters((char**)filter_fixture);

  first_action = filters->actions;
  second_action = (filters->actions + 1);

  first_validations = first_action->validations;
  second_validations = second_action->validations;

  munit_assert_int(filters->num_actions, ==, 2);

  munit_assert_int(first_action->num_validations, ==, 1);
  munit_assert_int(first_action->type, ==, ALLOW);

  munit_assert_int(second_action->num_validations, ==, 1);
  munit_assert_int(second_action->type, ==, REJECT);

  munit_assert_string_equal("MyClass", *((char**)(*first_validations)->values));
  munit_assert_ptr_equal((*first_validations)->function, valid_name);

  munit_assert_string_equal("no", *((char**)(*second_validations)->values));
  munit_assert_ptr_equal((*second_validations)->function, valid_method);

  return MUNIT_OK;
}

static void*
multiple_filters_build_setup(const MunitParameter params[], void* user_data) {
  char **multiple_filters = malloc(sizeof(char*)*18);

  multiple_filters[0] = "2";
  multiple_filters[1] = "1";
  multiple_filters[2] = "1";
  multiple_filters[3] = "1";
  multiple_filters[4] = "validate_name";
  multiple_filters[5] = "1";
  multiple_filters[6] = "MyClass";
  multiple_filters[7] = "allow";
  multiple_filters[8] = "filter";
  multiple_filters[9] = "1";
  multiple_filters[10] = "1";
  multiple_filters[11] = "1";
  multiple_filters[12] = "validate_path";
  multiple_filters[13] = "1";
  multiple_filters[14] = "/my/path";
  multiple_filters[15] = "reject";
  multiple_filters[16] = "filter";
  multiple_filters[17] = NULL;

  return (void*)multiple_filters;
}

MunitResult
multiple_filters_build_test(const MunitParameter params[], void* filter_fixture) {
  filter *first_filter, *second_filter, *filters;
  action *first_action, *second_action;
  validation **first_validations, **second_validations;

  filters = build_filters((char**)filter_fixture);
  first_filter = filters;
  second_filter = filters + 1;

  first_action = first_filter->actions;
  second_action = second_filter->actions;

  first_validations = first_action->validations;
  second_validations = second_action->validations;

  munit_assert_int(first_filter->num_actions, ==, 1);
  munit_assert_int(second_filter->num_actions, ==, 1);

  munit_assert_int(first_action->num_validations, ==, 1);
  munit_assert_int(first_action->type, ==, ALLOW);

  munit_assert_int(second_action->num_validations, ==, 1);
  munit_assert_int(second_action->type, ==, REJECT);

  munit_assert_string_equal("MyClass", *((char**)(*first_validations)->values));
  munit_assert_ptr_equal((*first_validations)->function, valid_name);

  munit_assert_string_equal("/my/path", *((char**)(*second_validations)->values));
  munit_assert_ptr_equal((*second_validations)->function, valid_path);

  return MUNIT_OK;
}

MunitTest build_filter_tests[] = {
  {
    "when filter is simple",
    simple_filter_build_test,
    simple_filter_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter is simple and has an int value",
    simple_filter_int_value_build_test,
    simple_filter_int_value_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter has one validation with multiple values",
    single_filter_multi_value_validation_build_test,
    single_filter_multi_value_validation_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter has one validation with multiple values",
    single_filter_multiple_validations_build_test,
    single_filter_multiple_validations_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter has one validation with multiple values",
    single_filter_multiple_validations_build_test,
    single_filter_multiple_validations_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter has parallel validations with one values",
    single_filter_parallel_validations_build_test,
    single_filter_parallel_validations_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when filter has multiple actions",
    single_filter_multiple_actions_build_test,
    single_filter_multiple_actions_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are multiple filters",
    multiple_filters_build_test,
    multiple_filters_build_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

MunitSuite build_filter_suite = {
  "build_filter ",
  build_filter_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
