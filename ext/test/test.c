#define MUNIT_ENABLE_ASSERT_ALIASES
#include "munit/munit.h"
#include "event_processor.h"
#include "event_processor/pop_stack_to_list_test.h"

extern const MunitSuite pop_stack_to_list_suite; 

void main(int argc, const char* argv[]) {
  munit_suite_main(&pop_stack_to_list_suite, NULL, argc, argv);
}
