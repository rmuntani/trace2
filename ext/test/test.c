#define MUNIT_ENABLE_ASSERT_ALIASES
#include "munit/munit.h"
#include "event_processor/suite.h"
#include "query_use/suite.h"
#include "summarizer/suite.h"

#define NUMBER_OF_SUITES 3

void main(int argc, const char* argv[]) {
  MunitSuite *suites = malloc(sizeof(MunitSuite)*NUMBER_OF_SUITES);
  MunitSuite *suite_head = suites;

  MunitSuite suite = {
    "extension suite ",
    NULL,
    NULL,
    1,
    MUNIT_SUITE_OPTION_NONE
  };

  *suites = *(event_processor_suite());
  suites++;
  *suites = *(query_use_suite());
  suites++;
  *suites = *(summarizer_suite());

  suite.suites = suite_head;

  munit_suite_main(&suite, NULL, argc, argv);
}
