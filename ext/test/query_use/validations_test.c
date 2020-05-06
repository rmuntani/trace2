#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

static void*
valid_name_setup(const MunitParameter params[], void* user_data) {
  class_use* use = malloc(sizeof(class_use));

  use->name = "MyClass";

  return use;
}

MunitResult
valid_name_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** name = malloc(sizeof(char*)*2);
  name[0] = "MyClass";
  name[1] = NULL;

  valid = valid_name(class_use, name);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_names_valid_name_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** name = malloc(sizeof(char*)*3);
  name[0] = "YourClass";
  name[1] = "MyClass";
  name[2] = NULL;

  valid = valid_name(class_use, name);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_invalid_names_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** name = malloc(sizeof(char*)*3);
  name[0] = "YourClass";
  name[1] = "OurClass";
  name[2] = NULL;

  valid = valid_name(class_use, name);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitTest validations_tests[] = {
  {
    "when name is valid",
    valid_name_test,
    valid_name_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when one of many names is valid",
    multiple_names_valid_name_test,
    valid_name_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when none of many names is valid",
    multiple_invalid_names_test,
    valid_name_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

MunitSuite validations_suite = {
  "validations ",
  validations_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
