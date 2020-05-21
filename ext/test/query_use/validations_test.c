#include "../munit/munit.h"
#include "event_processor.h"
#include "query_use.h"

static void*
valid_setup(const MunitParameter params[], void* user_data) {
  class_use* use = malloc(sizeof(class_use));

  use->name = "MyClass";
  use->method = "yes";
  use->path = "/var";
  use->lineno = 8;
  use->caller = NULL;
  use->head_callee = NULL;
  use->tail_callee = NULL;

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

MunitResult
valid_method_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** method = malloc(sizeof(char*)*2);
  method[0] = "yes";
  method[1] = NULL;

  valid = valid_method(class_use, method);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_methods_valid_method_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** method = malloc(sizeof(char*)*3);
  method[0] = "no";
  method[1] = "yes";
  method[2] = NULL;

  valid = valid_method(class_use, method);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_invalid_methods_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** method = malloc(sizeof(char*)*3);
  method[0] = "no";
  method[1] = "maybe";
  method[2] = NULL;

  valid = valid_method(class_use, method);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitResult
valid_path_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** path = malloc(sizeof(char*)*2);
  path[0] = "/var";
  path[1] = NULL;

  munit_log(MUNIT_LOG_WARNING, "OK");
  valid = valid_path(class_use, path);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_paths_valid_path_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** path = malloc(sizeof(char*)*3);
  path[0] = "/var/lib";
  path[1] = "/var";
  path[2] = NULL;

  valid = valid_path(class_use, path);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_invalid_paths_test(const MunitParameter params[], void* class_use) {
  int valid;
  char** path = malloc(sizeof(char*)*3);
  path[0] = "/root";
  path[1] = "/bin";
  path[2] = NULL;

  valid = valid_path(class_use, path);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitResult
valid_lineno_test(const MunitParameter params[], void* class_use) {
  int valid;
  int* lineno = malloc(sizeof(int)*3);
  lineno[0] = 8;
  lineno[1] = 0;

  valid = valid_lineno(class_use, lineno);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_linenos_valid_lineno_test(const MunitParameter params[], void* class_use) {
  int valid;
  int* lineno = malloc(sizeof(int)*3);
  lineno[0] = 17;
  lineno[1] = 8;
  lineno[2] = 0;

  valid = valid_lineno(class_use, lineno);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitResult
multiple_invalid_linenos_test(const MunitParameter params[], void* class_use) {
  int valid;
  int* lineno = malloc(sizeof(int)*3);
  lineno[0] = 17;
  lineno[1] = 13;
  lineno[2] = 0;

  valid = valid_lineno(class_use, lineno);

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitResult
valid_top_of_stack_test(const MunitParameter params[], void* class_use) {
  int valid, is_top = 1;

  valid = valid_top_of_stack(class_use, (void*)(&is_top));

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

static void*
invalid_top_of_stack_setup(const MunitParameter params[], void* user_data) {
  class_use* use = malloc(sizeof(class_use));

  use->head_callee = malloc(sizeof(class_use));

  return use;
}

MunitResult
invalid_top_of_stack_test(const MunitParameter params[], void* class_use) {
  int valid, is_top = 1;

  valid = valid_top_of_stack(class_use, (void*)(&is_top));

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

MunitResult
valid_bottom_of_stack_test(const MunitParameter params[], void* class_use) {
  int valid, is_bottom = 0;

  valid = valid_bottom_of_stack(class_use, (void*)(&is_bottom));

  munit_assert_int(valid, ==, 0);

  return MUNIT_OK;
}

static void*
invalid_bottom_of_stack_setup(const MunitParameter params[], void* user_data) {
  class_use* use = malloc(sizeof(class_use));

  use->caller = malloc(sizeof(class_use));

  return use;
}

MunitResult
invalid_bottom_of_stack_test(const MunitParameter params[], void* class_use) {
  int valid, is_bottom = 0;

  valid = valid_bottom_of_stack(class_use, (void*)&is_bottom);

  munit_assert_int(valid, ==, 1);

  return MUNIT_OK;
}

MunitTest validations_tests[] = {
  {
    "when method is valid",
    valid_method_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when one of many methods is valid",
    multiple_methods_valid_method_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when none of many methods is valid",
    multiple_invalid_methods_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when method is valid",
    valid_method_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when one of many methods is valid",
    multiple_methods_valid_method_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when none of many methods is valid",
    multiple_invalid_methods_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when path is valid",
    valid_path_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when one of many paths is valid",
    multiple_paths_valid_path_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when none of many paths is valid",
    multiple_invalid_paths_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when lineno is valid",
    valid_lineno_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when one of many linenos is valid",
    multiple_linenos_valid_lineno_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when none of many linenos is valid",
    multiple_invalid_linenos_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when class is top of stack (has no callees)",
    valid_top_of_stack_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when class is not top of stack (has callees)",
    invalid_top_of_stack_test,
    invalid_top_of_stack_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when class is bottom of stack (has no caller)",
    valid_bottom_of_stack_test,
    valid_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when class is not bottom of stack (has caller)",
    invalid_bottom_of_stack_test,
    invalid_bottom_of_stack_setup,
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
