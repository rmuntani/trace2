#!/bin/bash

echo 'Compiling tests...'
gcc -g -I ext/test \
       ext/trace2/event_processor.c \
       ext/trace2/query_use.c \
       ext/trace2/name_finder.c \
       ext/test/munit/munit.c \
       ext/test/ruby.c \
       ext/test/event_processor/add_callee_to_caller_test.c \
       ext/test/event_processor/clear_test.c \
       ext/test/event_processor/insert_test.c \
       ext/test/event_processor/pop_test.c \
       ext/test/event_processor/pop_stack_to_list_test.c \
       ext/test/event_processor/push_new_class_use_test.c \
       ext/test/event_processor/push_test.c \
       ext/test/query_use/validations_test.c \
       ext/test/query_use/run_validations_test.c \
       ext/test/query_use/run_actions_test.c \
       ext/test/query_use/count_occurrences_test.c \
       ext/test/query_use/find_position_test.c \
       ext/test/query_use/suite.c \
       ext/test/event_processor/suite.c \
       ext/test/test.c -o test.o

echo 'Running tests...'
./test.o --log-visible debug

echo 'Removing compiled file...'
rm test.o
