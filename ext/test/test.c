#define MUNIT_ENABLE_ASSERT_ALIASES
#include "munit/munit.h"
#include "event_processor/suite.h"

void main(int argc, const char* argv[]) {
  MunitSuite *suites = malloc(sizeof(MunitSuite));

  MunitSuite suite = {
    "extension suite ",
    NULL,
    NULL,
    1,
    MUNIT_SUITE_OPTION_NONE
  };

  *suites = *(event_processor_suite());
  suite.suites = suites;

  munit_suite_main(&suite, NULL, argc, argv);
}
