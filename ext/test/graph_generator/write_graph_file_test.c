#include <stdio.h>
#include "../munit/munit.h"
#include "graph_generator.h"

static void
write_graph_file_tear_down(void *fixture) {
  remove("graph.txt");
}

static void*
empty_string_write_graph_file_setup(const MunitParameter params[], void* user_data) {
  char** str = malloc(sizeof(char*));

  *str = NULL;

  return (void*)str;
}

MunitResult
empty_string_write_graph_file_test(const MunitParameter params[], void* str) {
  FILE *file;
  char first_line[256], second_line[256];

  write_graph_file("graph.txt", (char**)str);

  file = fopen("graph.txt", "r");
  fgets(first_line, 256, file);
  fgets(second_line, 256, file);

  munit_assert_string_equal(first_line, "digraph {\n");
  munit_assert_string_equal(second_line, "}");

  return MUNIT_OK;
}

static void*
write_graph_file_setup(const MunitParameter params[], void* user_data) {
  char** str = malloc(sizeof(char*)*4);

  *str = "FirstUse -> Use";
  *(str + 1) = "SecondUse -> Use";
  *(str + 2) = "ThirdUse -> Use";
  *(str + 3) = NULL;

  return (void*)str;
}

MunitResult
write_graph_file_test(const MunitParameter params[], void* str) {
  FILE *file;
  char first_line[256], second_line[256],
       third_line[256], fourth_line[256],
       fifth_line[256];

  write_graph_file("graph.txt", (char**)str);

  file = fopen("graph.txt", "r");
  fgets(first_line, 256, file);
  fgets(second_line, 256, file);
  fgets(third_line, 256, file);
  fgets(fourth_line, 256, file);
  fgets(fifth_line, 256, file);

  munit_assert_string_equal(first_line, "digraph {\n");
  munit_assert_string_equal(second_line, "\tFirstUse -> Use\n");
  munit_assert_string_equal(third_line, "\tSecondUse -> Use\n");
  munit_assert_string_equal(fourth_line, "\tThirdUse -> Use\n");
  munit_assert_string_equal(fifth_line, "}");

  return MUNIT_OK;
}

MunitTest write_graph_file_tests[] = {
  {
    "when the strings are empty",
    empty_string_write_graph_file_test,
    empty_string_write_graph_file_setup,
    write_graph_file_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when the strings are not empty",
    write_graph_file_test,
    write_graph_file_setup,
    write_graph_file_tear_down,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite write_graph_file_suite = {
  "write_graph_file ",
  write_graph_file_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
