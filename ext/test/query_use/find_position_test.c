#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

static void*
find_position_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*5);

  words[0] = "filter";
  words[1] = "super";
  words[2] = "incredible";
  words[3] = "filter";
  words[4] = NULL;

  return (void*)words;
}

MunitResult
find_position_with_null_start_test(const MunitParameter params[], void* words) {
  int occurrences = find_position("super", words, 0);

  munit_assert_int(occurrences, ==, 1);

  return MUNIT_OK;
}

MunitResult
find_position_with_non_null_start_test(const MunitParameter params[], void* words) {
  int occurrences = find_position("filter", words, 1);

  munit_assert_int(occurrences, ==, 3);

  return MUNIT_OK;
}

MunitResult
find_position_fail_test(const MunitParameter params[], void* words) {
  int occurrences = find_position("amazing", words, 0);

  munit_assert_int(occurrences, ==, -1);

  return MUNIT_OK;
}

MunitResult
find_position_start_after_end_test(const MunitParameter params[], void* words) {
  int occurrences = find_position("amazing", words, 300);

  munit_assert_int(occurrences, ==, -1);

  return MUNIT_OK;
}

MunitTest find_position_tests[] = {
  {
    "when start is 0",
    find_position_with_null_start_test,
    find_position_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when start is not 0",
    find_position_with_non_null_start_test,
    find_position_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when word is not in the array",
    find_position_fail_test,
    find_position_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when start is after end of the array",
    find_position_start_after_end_test,
    find_position_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite find_position_suite = {
  "find_position ",
  find_position_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
