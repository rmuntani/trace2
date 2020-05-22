#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

class_use *callee;

static void
valid_caller_class_teardown(void *fixture) {
  free(callee->caller->caller);
  free(callee->caller);
  free(callee);
  free(fixture);
}

static void
create_callee() {
  class_use *direct_caller, *indirect_caller;

  indirect_caller = malloc(sizeof(class_use));
  indirect_caller->name = "TheirClass";
  indirect_caller->method = "no";
  indirect_caller->caller = NULL;

  direct_caller = malloc(sizeof(class_use));
  direct_caller->name = "OurClass";
  direct_caller->method = "no";
  direct_caller->caller = indirect_caller;

  callee = malloc(sizeof(class_use));
  callee->caller = direct_caller;
  callee->name = "MyClass";
}

static void*
valid_direct_caller_class_setup(const MunitParameter params[], void* user_data) {
  validation* curr_validation = malloc(sizeof(validation)*3);
  char** names = malloc(sizeof(char*)*3);
  char** methods = malloc(sizeof(char*)*2);

  names[0] = "NotClass";
  names[1] = "OurClass";
  names[2] = NULL;

  methods[0] = "no";
  methods[1] = NULL;

  create_callee();

  curr_validation[0].function = valid_name;
  curr_validation[0].values = (void*)names;

  curr_validation[1].function = valid_method;
  curr_validation[1].values = (void*)methods;

  curr_validation[2].function = NULL;

  return curr_validation;
}

MunitResult
valid_direct_caller_class_test(const MunitParameter params[], void* validations) {
  int valid;

  valid = valid_caller_class(callee, (validation*)validations);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
valid_indirect_caller_class_setup(const MunitParameter params[], void* user_data) {
  validation* curr_validation = malloc(sizeof(validation)*3);
  char** names = malloc(sizeof(char*)*3);
  char** methods = malloc(sizeof(char*)*2);

  names[0] = "NotClass";
  names[1] = "TheirClass";
  names[2] = NULL;

  methods[0] = "no";
  methods[1] = NULL;

  create_callee();

  curr_validation[0].function = valid_name;
  curr_validation[0].values = (void*)names;

  curr_validation[1].function = valid_method;
  curr_validation[1].values = (void*)methods;

  curr_validation[2].function = NULL;

  return curr_validation;
}

MunitResult
valid_indirect_caller_class_test(const MunitParameter params[], void* validations) {
  int valid;

  valid = valid_caller_class(callee, (validation*)validations);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
invalid_caller_class_setup(const MunitParameter params[], void* user_data) {
  validation* curr_validation = malloc(sizeof(validation)*3);
  char** names = malloc(sizeof(char*)*3);
  char** methods = malloc(sizeof(char*)*2);

  names[0] = "NotClass";
  names[1] = "TheirClass";
  names[2] = NULL;

  methods[0] = "yes";
  methods[1] = NULL;

  create_callee();

  curr_validation[0].function = valid_name;
  curr_validation[0].values = (void*)names;

  curr_validation[1].function = valid_method;
  curr_validation[1].values = (void*)methods;

  curr_validation[2].function = NULL;

  return curr_validation;
}

MunitResult
invalid_caller_class_test(const MunitParameter params[], void* validations) {
  int valid;

  valid = valid_caller_class(callee, (validation*)validations);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitTest valid_caller_class_tests[] = {
  {
    "when the direct caller matches the filter",
    valid_direct_caller_class_test,
    valid_direct_caller_class_setup,
    valid_caller_class_teardown,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when the indirect caller matches the filter",
    valid_indirect_caller_class_test,
    valid_indirect_caller_class_setup,
    valid_caller_class_teardown,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when the no caller matches the filter",
    invalid_caller_class_test,
    invalid_caller_class_setup,
    valid_caller_class_teardown,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite valid_caller_class_suite = {
  "valid_caller_class ",
  valid_caller_class_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
