#!/bin/bash

echo 'Removing old files...'
rm -rf tmp/
find . -name '*.so' -exec rm {} \;
find . -name '*.o' -exec rm {} \;

echo 'Recompiling extension...'
rake compile
