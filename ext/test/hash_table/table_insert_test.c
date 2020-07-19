#include "../munit/munit.h"
#include "hash_table.h"

__attribute__((weak)) long hash(unsigned char *str) {
  return 1;
}

static void*
empty_table_insert_setup(const MunitParameter params[], void* user_data) {
  hash_table *table = create_table(3);

  return (void*)table;
}

MunitResult
empty_table_insert_test(const MunitParameter params[], void* fixture_table) {
  hash_table *table = (hash_table*)fixture_table;
  table_item *node;
  int successful_insert = table_insert(table, (void*)4, "testing");

  node = table->table[1];

  munit_assert_int(1, ==, successful_insert);
  munit_assert_ptr_equal(node->next, NULL);
  munit_assert_int(4, ==, (int)node->value);
  munit_assert_string_equal(node->key, "testing");

  return MUNIT_OK;
}

static void*
collision_table_insert_setup(const MunitParameter params[], void* user_data) {
  hash_table *table = create_table(3);
  table_item *node = malloc(sizeof(table_item));

  node->value = (void*)3;
  node->key = "not_testing";
  node->next = NULL;

  table->table[1] = node;

  return (void*)table;
}

MunitResult
collision_table_insert_test(const MunitParameter params[], void* fixture_table) {
  hash_table *table = (hash_table*)fixture_table;
  table_item *node;
  int successful_insert = table_insert(table, (void*)4, "testing");

  node = table->table[1];

  munit_assert_int(1, ==, successful_insert);

  munit_assert_ptr_not_equal(node->next, NULL);
  munit_assert_ptr_equal(node->next->next, NULL);

  munit_assert_int(3, ==, (int)node->value);

  munit_assert_int(4, ==, (int)node->next->value);
  munit_assert_string_equal(node->next->key, "testing");

  return MUNIT_OK;
}

static void*
repeated_key_table_insert_setup(const MunitParameter params[], void* user_data) {
  hash_table *table = create_table(3);
  table_item *node = malloc(sizeof(table_item));

  node->value = (void*)3;
  node->key = "testing";
  node->next = NULL;

  table->table[1] = node;

  return (void*)table;
}

MunitResult
repeated_key_table_insert_test(const MunitParameter params[], void* fixture_table) {
  hash_table *table = (hash_table*)fixture_table;
  table_item *node;
  int successful_insert = table_insert(table, (void*)4, "testing");

  node = table->table[1];

  munit_assert_int(0, ==, successful_insert);

  munit_assert_ptr_equal(node->next, NULL);

  munit_assert_int(3, ==, (int)node->value);
  munit_assert_string_equal(node->key, "testing");

  return MUNIT_OK;
}

MunitTest table_insert_tests[] = {
  {
    "when table is empty ",
    empty_table_insert_test,
    empty_table_insert_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when inserting a key causes a collision ",
    collision_table_insert_test,
    collision_table_insert_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when a repeated key is inserted",
    repeated_key_table_insert_test,
    repeated_key_table_insert_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite table_insert_suite = {
  "table_insert ",
  table_insert_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
