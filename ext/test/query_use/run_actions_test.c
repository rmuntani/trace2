#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

action *actions;
class_use* use;

static int stub_true_validation(class_use *use, void *x) {
  return 1;
}

static int stub_false_validation(class_use *use, void *x) {
  return 0;
}

static void
run_actions_tear_down(void *fixture) {
  free(actions);
  free(use);
}

static void*
single_validation_allow_run_setup(const MunitParameter params[], void* user_data) {
  validation **validations;

  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation*));
  *validations = malloc(sizeof(validation)*2);
  actions = malloc(sizeof(actions)*2);

  (*validations)->function = stub_true_validation;
  (*validations)->values = NULL;

  (*validations + 1)->function = NULL;
  (*validations + 1)->values = NULL;

  actions->validations = validations;
  actions->num_validations = 1;
  actions->type = ALLOW;

  (*(actions + 1)).type = NONE;
}

MunitResult
single_validation_allow_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
single_validation_reject_run_setup(const MunitParameter params[], void* user_data) {
  validation **validations;

  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation*));
  *validations = malloc(sizeof(validation)*3);
  actions = malloc(sizeof(actions)*2);

  (*validations)->function = stub_true_validation;
  (*validations)->values = NULL;

  (*validations + 1)->function = NULL;
  (*validations + 1)->values = NULL;

  actions->validations = validations;
  actions->num_validations = 1;
  actions->type = REJECT;

  (*(actions + 1)).type = NONE;
}

MunitResult
single_validation_reject_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

static void*
series_validation_reject_run_setup(const MunitParameter params[], void* user_data) {
  validation **validations;

  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation*)*1);
  actions = malloc(sizeof(actions));

  (*validations) = malloc(sizeof(validation)*3);

  (*validations)->function = stub_true_validation;
  (*validations)->values = NULL;

  (*validations + 1)->function = stub_false_validation;
  (*validations + 1)->values = NULL;

  (*validations + 2)->function = NULL;
  (*validations + 2)->values = NULL;

  actions->validations = validations;
  actions->type = REJECT;
  actions->num_validations = 1;

  munit_logf(MUNIT_LOG_WARNING, "validations: %p", validations);

  (*(actions + 1)).type = NONE;
}

MunitResult
series_validation_reject_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
parallel_validation_allow_run_setup(const MunitParameter params[], void* user_data) {
  validation **validations;

  use = malloc(sizeof(class_use));
  validations = malloc(sizeof(validation*)*2);
  actions = malloc(sizeof(actions));

  (*validations) = malloc(sizeof(validation)*2);
  *(validations+1) = malloc(sizeof(validation)*2);

  (*validations)->function = stub_false_validation;
  (*validations)->values = NULL;

  (*validations + 1)->function = NULL;
  (*validations + 1)->values = NULL;

  (*(validations + 1))->function = stub_true_validation;
  (*(validations + 1))->values = NULL;

  (*(validations + 1))->function = NULL;
  (*(validations + 1))->values = NULL;

  actions->validations = validations;
  actions->type = ALLOW;
  actions->num_validations = 2;

  (*(actions + 1)).type = NONE;
}

MunitResult
parallel_validation_allow_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
single_validation_multiple_actions_run_setup(const MunitParameter params[], void* user_data) {
  validation **first_validations, **second_validations;

  use = malloc(sizeof(class_use));

  first_validations = malloc(sizeof(validation*));
  *first_validations = malloc(sizeof(validation)*2);

  second_validations = malloc(sizeof(validation*));
  *second_validations = malloc(sizeof(validation)*2);

  actions = malloc(sizeof(actions)*3);


  (*first_validations)->function = stub_false_validation;
  (*first_validations)->values = NULL;

  (*first_validations + 1)->function = NULL;
  (*first_validations + 1)->values = NULL;

  (*second_validations)->function = stub_false_validation;
  (*second_validations)->values = NULL;

  (*second_validations + 1)->function = NULL;
  (*second_validations + 1)->values = NULL;

  actions->validations = first_validations;
  actions->type = ALLOW;
  actions->num_validations = 1;

  (actions + 1)->validations = second_validations;
  (actions + 1)->type = ALLOW;
  (actions + 1)->num_validations = 1;

  (actions + 2)->type = NONE;
}

MunitResult
single_validation_multiple_actions_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

static void*
single_action_integration_run_setup(const MunitParameter params[], void* user_data) {
  char **paths, **first_name, **second_names, **methods;
  validation **validations;

  paths = malloc(sizeof(char*)*2);
  paths[0] = "/our/path";
  paths[1] = NULL;

  methods = malloc(sizeof(char*)*2);
  methods[0] = "no";
  methods[1] = NULL;

  first_name = malloc(sizeof(char*)*3);
  first_name[0] = "OurClass";
  first_name[1] = "MyClass";
  first_name[2] = NULL;

  second_names = malloc(sizeof(char*)*2);
  second_names[0] = "OurClass";
  second_names[1] = NULL;

  use = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "yes";
  use->lineno = 24;
  use->path = "/my/path";

  validations = malloc(sizeof(validation*)*3); // 3 parallel validations

  *validations = malloc(sizeof(validation)*2);

  (*validations)->function = valid_path;
  (*validations)->values = (void*)paths;

  (*validations + 1)->function = NULL;
  (*validations + 1)->values = NULL;

  *(validations + 1) = malloc(sizeof(validation)*3);

  (*(validations + 1))->function = valid_method;
  (*(validations + 1))->values = (void*)methods;

  (*(validations + 1) + 1)->function = valid_name;
  (*(validations + 1) + 1)->values = (void*)second_names;

  (*(validations + 1) + 2)->function = NULL;
  (*(validations + 1) + 2)->values = NULL;

  *(validations + 2) = malloc(sizeof(validation)*2);

  (*(validations + 2))->function = valid_name;
  (*(validations + 2))->values = (void*)first_name;

  (*(validations + 2) + 1)->function = NULL;
  (*(validations + 2) + 1)->values = NULL;

  actions = malloc(sizeof(actions)*2);

  actions->validations = validations;
  actions->type = ALLOW;
  actions->num_validations = 3;

  (actions + 1)->type = NONE;
}

MunitResult
single_action_integration_run_test(const MunitParameter params[], void* user_data) {
  int valid = run_actions(actions, use);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitTest run_actions_tests[] = {
  {
    "when there is one allow with one validation",
    single_validation_allow_run_test,
    single_validation_allow_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one reject with one validation",
    single_validation_reject_run_test,
    single_validation_reject_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one reject with a validation in series",
    series_validation_reject_run_test,
    series_validation_reject_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one allow with validations in parallel",
    parallel_validation_allow_run_test,
    parallel_validation_allow_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are multiple actions with one validation",
    single_validation_multiple_actions_run_test,
    single_validation_multiple_actions_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there one action is run with real validations",
    single_action_integration_run_test,
    single_action_integration_run_setup,
    run_actions_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite run_actions_suite = {
  "run_actions ",
  run_actions_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
