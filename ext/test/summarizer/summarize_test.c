#include "../munit/munit.h"
#include "summarizer.h"

static void
summarize_tear_down(void *fixture) {}

static void*
summarize_setup(const MunitParameter params[], void* user_data) {

  return (void*)0;
}

MunitResult
summarize_test(const MunitParameter params[], void* user_data_setup) {
  return MUNIT_OK;
}

MunitTest summarize_tests[] = {
  {
    "placeholder test ",
    summarize_test,
    summarize_setup,
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
