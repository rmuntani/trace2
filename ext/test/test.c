#define MUNIT_ENABLE_ASSERT_ALIASES
#include "munit/munit.h"
#include "event_processor.h"
#include "event_processor/pop_test.h"
#include "event_processor/insert_test.h"

extern const MunitSuite pop_stack_to_list_suite; 
extern const MunitSuite pop_suite; 

void main(int argc, const char* argv[]) {
  MunitSuite suites[] = {
    pop_suite, insert_suite, NULL
  };

  MunitSuite suite = {
    "event_processor ",
    NULL,
    NULL,
    1,
    MUNIT_SUITE_OPTION_NONE
  };
  suite.suites = suites;

  munit_suite_main(&suite, NULL, argc, argv);
}
