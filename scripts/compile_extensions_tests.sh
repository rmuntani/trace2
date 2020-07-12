#!/bin/bash

echo 'Compiling tests...'
gcc -g -I ext/test \
       ext/trace2/event_processor.c \
       ext/trace2/name_finder.c \
       ext/trace2/graph_generator.c \
       ext/trace2/hash_table.c \
       ext/trace2/query_use.c \
       ext/test/munit/munit.c \
       ext/test/regex.c \
       ext/test/ruby.c \
       ext/test/event_processor/add_callee_to_caller_test.c \
       ext/test/event_processor/clear_test.c \
       ext/test/event_processor/insert_test.c \
       ext/test/event_processor/pop_test.c \
       ext/test/event_processor/pop_stack_to_list_test.c \
       ext/test/event_processor/push_new_class_use_test.c \
       ext/test/event_processor/push_test.c \
       ext/test/graph_generator/graph_strings_test.c \
       ext/test/graph_generator/suite.c \
       ext/test/hash_table/create_table_test.c \
       ext/test/hash_table/table_insert_test.c \
       ext/test/hash_table/suite.c \
       ext/test/query_use/validations_test.c \
       ext/test/query_use/run_validations_test.c \
       ext/test/query_use/run_actions_test.c \
       ext/test/query_use/build_filter_test.c \
       ext/test/query_use/run_filters_test.c \
       ext/test/query_use/valid_caller_class_test.c \
       ext/test/query_use/suite.c \
       ext/test/event_processor/suite.c \
       ext/test/test.c -o test.o

echo 'Compiled tests output file is test.o'
