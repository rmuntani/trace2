#!/bin/bash

scripts/compile_extensions_tests.sh

echo 'Running tests...'
./test.o --log-visible debug

echo 'Removing test file...'
rm test.o
