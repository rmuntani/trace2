# !/bin/bash

version=$(grep version trace2.gemspec | awk '{ print $3 }' | tr -d "'")

scripts/build_gem.sh
gem push "trace2-$version.gem"
