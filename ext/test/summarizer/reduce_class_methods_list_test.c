#include "../munit/munit.h"
#include "summarizer.h"
#include "helper.h"

static void*
different_classes_reduce_methods_list_setup(const MunitParameter params[], void* user_data) {
  char *first_methods[] = { "yes", NULL };
  char *second_methods[] = { "no", NULL };
  class_methods *first = create_fixture_class_methods("FirstClass", first_methods),
                *second = create_fixture_class_methods("SecondClass", second_methods);
  list *first_node = wrap_list(first),
       *second_node = wrap_list(second),
       **fixture = malloc(sizeof(list*)*2);

  fixture[0] = first_node;
  fixture[1] = second_node;

  return (void*)fixture;
}

MunitResult
different_classes_reduce_methods_list_test(const MunitParameter params[], void* lists) {
  list *first_node = *((list**)lists),
       *second_node = *((list**)lists + 1);

  reduce_class_methods_list(first_node, second_node);

  class_methods *first_class = (class_methods*)first_node->value,
                *second_class = (class_methods*)first_node->next->value;

  munit_assert_ptr_not_equal(first_node, NULL);
  munit_assert_ptr_not_equal(first_node->next, NULL);
  munit_assert_ptr_equal(first_node->next->next, NULL);

  munit_assert_string_equal(first_class->name, "FirstClass");
  munit_assert_string_equal(method_name(first_class->methods), "yes");
  munit_assert_ptr_equal(first_class->methods->next, NULL);

  munit_assert_string_equal(second_class->name, "SecondClass");
  munit_assert_string_equal(method_name(second_class->methods), "no");
  munit_assert_ptr_equal(second_class->methods->next, NULL);

  return MUNIT_OK;
}

static void*
same_class_diferent_method_reduce_methods_list_setup(const MunitParameter params[], void* user_data) {
  char *first_methods[] = { "yes", NULL };
  char *second_methods[] = { "no", NULL };
  class_methods *first = create_fixture_class_methods("MyClass", first_methods),
                *second = create_fixture_class_methods("MyClass", second_methods);
  list *first_node = wrap_list(first),
       *second_node = wrap_list(second),
       **fixture = malloc(sizeof(list*)*2);

  fixture[0] = first_node;
  fixture[1] = second_node;

  return (void*)fixture;
}

MunitResult
same_class_diferent_method_reduce_methods_list_test(const MunitParameter params[], void* lists) {
  list *first_node = *((list**)lists),
       *second_node = *((list**)lists + 1);

  reduce_class_methods_list(first_node, second_node);

  class_methods *only_class = (class_methods*)first_node->value;

  munit_assert_ptr_not_equal(first_node, NULL);
  munit_assert_ptr_equal(first_node->next, NULL);

  munit_assert_string_equal(only_class->name, "MyClass");
  munit_assert_string_equal(method_name(only_class->methods), "yes");
  munit_assert_string_equal(method_name(only_class->methods->next), "no");
  munit_assert_ptr_equal(only_class->methods->next->next, NULL);

  return MUNIT_OK;
}

static void*
duplicated_class_reduce_methods_list_setup(const MunitParameter params[], void* user_data) {
  char *only_methods[] = { "yes", NULL };
  class_methods *only_class = create_fixture_class_methods("MyClass", only_methods);
  list *only_node = wrap_list(only_class),
       **fixture = malloc(sizeof(list*)*2);

  fixture[0] = only_node;
  fixture[1] = only_node;

  return (void*)fixture;
}

MunitResult
duplicated_class_reduce_methods_list_test(const MunitParameter params[], void* lists) {
  list *first_node = *((list**)lists),
       *second_node = *((list**)lists + 1);
  munit_log(MUNIT_LOG_WARNING, "duddudududu");
  reduce_class_methods_list(first_node, second_node);
  munit_log(MUNIT_LOG_WARNING, "duddudududu");

  class_methods *only_class = (class_methods*)first_node->value;

  munit_assert_ptr_not_equal(first_node, NULL);
  munit_assert_ptr_equal(first_node->next, NULL);

  munit_assert_string_equal(only_class->name, "MyClass");
  munit_assert_string_equal(method_name(only_class->methods), "yes");
  munit_assert_ptr_equal(only_class->methods->next, NULL);

  return MUNIT_OK;
}

static void*
multiple_class_methods_reduce_list_setup(const MunitParameter params[], void* user_data) {
  char *fst_fst_methods[] = { "yes", "no", "maybe", NULL };
  char *snd_fst_methods[] = { "no", NULL };
  char *fst_snd_methods[] = { "maybe", "sure", NULL };
  char *snd_snd_methods[] = { "no", "yes", NULL };
  char *third_methods[] = { "yes", NULL };

  class_methods *fst_fst = create_fixture_class_methods("FirstClass", fst_fst_methods),
                *fst_snd = create_fixture_class_methods("SecondClass", snd_fst_methods),
                *snd_fst = create_fixture_class_methods("FirstClass", fst_snd_methods),
                *snd_snd = create_fixture_class_methods("SecondClass", snd_snd_methods),
                *trd = create_fixture_class_methods("ThirdClass", third_methods);

  list *fst_fst_node = wrap_list(fst_fst),
       *fst_snd_node = wrap_list(fst_snd),
       *snd_fst_node = wrap_list(snd_fst),
       *snd_snd_node = wrap_list(snd_snd),
       *trd_node = wrap_list(trd),
       **fixture = malloc(sizeof(list*)*2);

  fst_fst_node->next = fst_snd_node;
  snd_fst_node->next = snd_snd_node;
  snd_snd_node->next = trd_node;

  fixture[0] = fst_fst_node;
  fixture[1] = snd_fst_node;

  return (void*)fixture;
}

MunitResult
multiple_class_methods_reduce_list_test(const MunitParameter params[], void* lists) {
  list *first_node = *((list**)lists),
       *second_node = *((list**)lists + 1);
  class_methods *fst_class, *snd_class, *trd_class;

  reduce_class_methods_list(first_node, second_node);

  fst_class = (class_methods*)first_node->value;
  snd_class = (class_methods*)first_node->next->value;
  trd_class = (class_methods*)first_node->next->next->value;

  munit_assert_ptr_equal(first_node->next->next->next, NULL);

  munit_assert_string_equal(fst_class->name, "FirstClass");
  munit_assert_string_equal(method_name(fst_class->methods), "yes");
  munit_assert_string_equal(method_name(fst_class->methods->next), "no");
  munit_assert_string_equal(method_name(fst_class->methods->next->next), "maybe");
  munit_assert_string_equal(method_name(fst_class->methods->next->next->next), "sure");
  munit_assert_ptr_equal(fst_class->methods->next->next->next->next, NULL);

  munit_assert_string_equal(snd_class->name, "SecondClass");
  munit_assert_string_equal(method_name(snd_class->methods), "no");
  munit_assert_string_equal(method_name(snd_class->methods->next), "yes");
  munit_assert_ptr_equal(snd_class->methods->next->next, NULL);

  munit_assert_string_equal(trd_class->name, "ThirdClass");
  munit_assert_string_equal(method_name(trd_class->methods), "yes");
  munit_assert_ptr_equal(trd_class->methods->next, NULL);

  return MUNIT_OK;
}

MunitTest reduce_class_methods_list_tests[] = {
  {
    "when classes are different ",
    different_classes_reduce_methods_list_test,
    different_classes_reduce_methods_list_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is one class use with different methods ",
    same_class_diferent_method_reduce_methods_list_test,
    same_class_diferent_method_reduce_methods_list_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there is a duplicated class use ",
    duplicated_class_reduce_methods_list_test,
    duplicated_class_reduce_methods_list_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  {
    "when there are a multiple class uses ",
    multiple_class_methods_reduce_list_test,
    multiple_class_methods_reduce_list_setup,
    NULL,
    MUNIT_TEST_OPTION_NONE,
    NULL
  },
  { NULL, NULL, NULL, NULL, MUNIT_TEST_OPTION_NONE, NULL }
};

const MunitSuite reduce_class_methods_list_suite = {
  "reduce_class_methods_list ",
  reduce_class_methods_list_tests,
  NULL,
  1,
  MUNIT_SUITE_OPTION_NONE
};
