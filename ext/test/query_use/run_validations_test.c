#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

validation *validations;
class_use* use;

static int stub_true_validation(class_use *use, void *x) {
  return 1;
}

static int stub_false_validation(class_use *use, void *x) {
  return 0;
}

static void
run_validations_tear_down(void *fixture) {
  free(validations);
  free(use);
}

static void*
single_true_validation_run_setup(const MunitParameter params[], void* user_data) {
  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation)*2);

  (*validations).function = stub_true_validation;
  (*validations).values = NULL;

  (*(validations + 1)).function = NULL;
  (*(validations + 1)).values = NULL;
}

MunitResult
single_true_validation_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_validations(validations, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
single_false_validation_run_setup(const MunitParameter params[], void* user_data) {
  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation)*2);

  validations->function = stub_false_validation;
  validations->values = NULL;

  (*(validations + 1)).function = NULL;
  (*(validations + 1)).values = NULL;
}

MunitResult
single_false_validation_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_validations(validations, use);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

static void*
multiple_validations_run_setup(const MunitParameter params[], void* user_data) {
  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation)*3);

  validations->function = stub_false_validation;
  validations->values = NULL;

  (*(validations + 1)).function = stub_true_validation;
  (*(validations + 1)).values = NULL;

  (*(validations + 2)).function = NULL;
  (*(validations + 2)).values = NULL;
}

MunitResult
multiple_validations_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_validations(validations, use);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

static void*
integration_run_validations_setup(const MunitParameter params[], void* user_data) {
  int* linenos = malloc(sizeof(int)*3);
  char** names = malloc(sizeof(char*)*3);

  *linenos = 3;
  *(linenos + 1) = 27;
  *(linenos + 2) = 0;

  *names = "MyName";
  *(names + 1) = "MyClass";
  *(names + 2) = NULL;

  use = malloc(sizeof(class_use));
  use->lineno = 27;
  use->name = "MyClass";

  validations = malloc(sizeof(validation)*3);

  validations->function = valid_name;
  validations->values = (void*)names;

  (*(validations + 1)).function = valid_lineno;
  (*(validations + 1)).values = (void*)linenos;

  (*(validations + 2)).function = NULL;
  (*(validations + 2)).values = NULL;
}

MunitResult
integration_run_validations_test(const MunitParameter params[], void* user_data) {
  int valid = run_validations(validations, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitTest run_validations_tests[] = {
  {
    "when there is a single true validation ",
    single_true_validation_run_test,
    single_true_validation_run_setup,
    run_validations_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is a single false validation ",
    single_false_validation_run_test,
    single_false_validation_run_setup,
    run_validations_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are multiple validations",
    multiple_validations_run_test,
    multiple_validations_run_setup,
    run_validations_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when the validations are run with real validations",
    integration_run_validations_test,
    integration_run_validations_setup,
    run_validations_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite run_validations_suite = {
  "run_validations ",
  run_validations_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
