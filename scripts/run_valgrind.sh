#!/bin/bash

scripts/compile_extensions_tests.sh

echo 'Running Valgrind...'
valgrind --leak-check=full ./test.o

echo 'Removing test file...'
rm test.o
