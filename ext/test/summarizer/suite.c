#include "munit/munit.h"
#include "summarize_test.h"
#include "reduce_uses_list_test.h"

#define NUMBER_OF_SUITES 2

MunitSuite *summarizer_suite() {
  MunitSuite *suite = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *summarizer = malloc(sizeof(MunitSuite));
  MunitSuite *suite_head = suite;

  *suite = summarize_suite;
  *suite++;
  *suite = reduce_uses_list_suite;

  summarizer->prefix =  "summarizer ";
  summarizer->tests = NULL;
  summarizer->iterations = 1;
  summarizer->options = MUNIT_SUITE_OPTION_NONE;
  summarizer->suites = suite_head;

  return summarizer;
}
