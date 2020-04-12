#!/bin/bash

echo 'Compiling tests...'
gcc -I ext/test \
       ext/trace2/event_processor.c \
       ext/trace2/name_finder.c \
       ext/test/munit/munit.c \
       ext/test/ruby.c \
       ext/test/event_processor/pop_stack_to_list_test.c \
       ext/test/test.c -o test.o

echo 'Running tests...'
./test.o --log-visible debug

echo 'Removing compiled file...'
rm test.o