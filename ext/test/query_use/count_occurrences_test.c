#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

static void*
count_occurrences_with_start_and_end_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*2);

  words[0] = "filter";
  words[1] = NULL;

  return (void*)words;
}

MunitResult
count_occurrences_with_start_and_end_test(const MunitParameter params[], void* words) {
  int occurrences = count_occurrences("filter", words, 0, 1);

  munit_assert_int(occurrences, ==, 1);

  return MUNIT_OK;
}

static void*
count_occurrences_without_end_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*2);

  words[0] = "filter";
  words[1] = NULL;

  return (void*)words;
}

MunitResult
count_occurrences_without_end_test(const MunitParameter params[], void* words) {
  int occurrences = count_occurrences("filter", words, 0, -1);

  munit_assert_int(occurrences, ==, 1);

  return MUNIT_OK;
}

static void*
count_occurrences_with_non_null_start_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*7);

  words[0] = "filter";
  words[1] = "me";
  words[2] = "you";
  words[3] = "filter";
  words[4] = "yes";
  words[5] = "filter";
  words[6] = NULL;

  return (void*)words;
}

MunitResult
count_occurrences_with_non_null_start_test(const MunitParameter params[], void* words) {
  int occurrences = count_occurrences("filter", words, 3, 6);

  munit_assert_int(occurrences, ==, 2);

  return MUNIT_OK;
}

static void*
count_occurrences_with_unbounded_end_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*7);

  words[0] = "filter";
  words[1] = "me";
  words[2] = "you";
  words[3] = "filter";
  words[4] = "yes";
  words[5] = "filter";
  words[6] = NULL;

  return (void*)words;
}

MunitResult
count_occurrences_with_unbounded_end_test(const MunitParameter params[], void* words) {
  int occurrences = count_occurrences("filter", words, 0, 10000);

  munit_assert_int(occurrences, ==, 3);

  return MUNIT_OK;
}

static void*
count_occurrences_with_bounded_start_and_end_setup(const MunitParameter params[], void* user_data) {
  char** words = malloc(sizeof(char*)*7);

  words[0] = "filter";
  words[1] = "me";
  words[2] = "you";
  words[3] = "filter";
  words[4] = "yes";
  words[5] = "filter";
  words[6] = NULL;

  return (void*)words;
}

MunitResult
count_occurrences_with_bounded_start_and_end_test(const MunitParameter params[], void* words) {
  int occurrences = count_occurrences("filter", words, 3, 5);

  munit_assert_int(occurrences, ==, 1);

  return MUNIT_OK;
}


MunitTest count_occurrences_tests[] = {
  {
    "when start is 0 and end is 1 for one word ",
    count_occurrences_with_start_and_end_test,
    count_occurrences_with_start_and_end_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when start is 0 and there is no end",
    count_occurrences_without_end_test,
    count_occurrences_without_end_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when start is not 0",
    count_occurrences_with_non_null_start_test,
    count_occurrences_with_non_null_start_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when end is not after array's end0",
    count_occurrences_with_unbounded_end_test,
    count_occurrences_with_unbounded_end_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when start is greater than 0 and end is less than the limit",
    count_occurrences_with_bounded_start_and_end_test,
    count_occurrences_with_bounded_start_and_end_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite count_occurrences_suite = {
  "count_occurrences ",
  count_occurrences_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
