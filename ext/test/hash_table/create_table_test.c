#include "../munit/munit.h"
#include "hash_table.h"

MunitResult
create_table_test(const MunitParameter params[], void* fixture_table) {
  hash_table *table = create_table(3);

  munit_assert_ptr_equal(table->table[0], NULL);
  munit_assert_ptr_equal(table->table[1], NULL);
  munit_assert_ptr_equal(table->table[2], NULL);

  return MUNIT_OK;
}

MunitTest create_table_tests[] = {
  {
    "create a table with empty items",
    create_table_test,
    NULL,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite create_table_suite = {
  "create_table ",
  create_table_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
