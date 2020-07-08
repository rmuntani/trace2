#include "munit/munit.h"
#include "table_insert_test.h"
#include "create_table_test.h"

#define NUMBER_OF_SUITES 2

MunitSuite *hash_table_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *hash_table = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = create_table_suite;
  *suite++;
  *suite = table_insert_suite;
  *suite++;

  hash_table->prefix =  "hash_table ";
  hash_table->tests = NULL;
  hash_table->iterations = 1;
  hash_table->options = MUNIT_SUITE_OPTION_NONE;
  hash_table->suites = suite_head;

  return hash_table;
}
