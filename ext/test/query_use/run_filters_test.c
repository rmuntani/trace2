#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

/* The tests on this file rely on build_filter, due to the
 * difficulty of building a filter */
static const class_use use = {
  "MyClass",
  "yes",
  "/my/path",
  24,
  NULL,
  NULL,
  NULL
};

static void*
simple_filter_run_setup(const MunitParameter params[], void* user_data) {
  char* filter_string[] = {
    "1", "2",
    "1", "1", "validate_name", "1", "MyClass", "allow",
    "1", "1", "validate_method", "1", "yes", "allow",
    "filter"
  };
  filter *filter = build_filters(filter_string);

  return (void*)filter;
}

MunitResult
simple_filter_run_test(const MunitParameter params[], void* curr_filter) {
  class_use *filtered_use = run_filters((filter*)curr_filter, &use);

  munit_assert_ptr_equal(filtered_use, &use);

  return MUNIT_OK;
}

static void*
fail_filter_run_setup(const MunitParameter params[], void* user_data) {
  char* filter_string[] = {
    "1", "2",
    "1", "2",
    "validate_name", "1", "MyClass",
    "validate_lineno", "1", "24", "allow",
    "1", "1",
    "validate_method", "2", "yes", "no", "reject",
    "filter"
  };
  filter *filter = build_filters(filter_string);

  return (void*)filter;
}

MunitResult
fail_filter_run_test(const MunitParameter params[], void* curr_filter) {
  class_use *filtered_use = run_filters((filter*)curr_filter, &use);

  munit_assert_ptr_equal(filtered_use, NULL);

  return MUNIT_OK;
}

static void*
multiple_filters_run_setup(const MunitParameter params[], void* user_data) {
  char* filter_string[] = {
    "2",
    "2",
    "1", "2",
    "validate_name", "1", "MyClass",
    "validate_lineno", "1", "24", "allow",
    "1", "1",
    "validate_method", "2", "maybe", "no", "reject",
    "filter"
    "1",
    "1", "1",
    "validate_path", "3", "/our/file", "/our/path", "/my/path",
    "allow",
    "filter"
  };
  filter *filter = build_filters(filter_string);

  return (void*)filter;
}

MunitResult
multiple_filters_run_test(const MunitParameter params[], void* curr_filter) {
  class_use *filtered_use = run_filters((filter*)curr_filter, &use);

  munit_assert_ptr_equal(filtered_use, &use);

  return MUNIT_OK;
}

MunitTest run_filters_tests[] = {
  {
    "when a simple filter runs",
    simple_filter_run_test,
    simple_filter_run_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when a simple failed filter runs",
    fail_filter_run_test,
    fail_filter_run_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when multiple filters run",
    multiple_filters_run_test,
    multiple_filters_run_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite run_filters_suite = {
  "run_filters ",
  run_filters_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
