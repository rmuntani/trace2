#!/bin/bash

scripts/compile_extensions_tests.sh

echo 'Running Valgrind...'
valgrind ./test.o

echo 'Removing test file...'
rm test.o
