#!/bin/bash
version=$(grep version trace2.gemspec | awk '{ print $3 }' | tr -d "'")
rm -rf trace2-*
gem build trace2.gemspec
gem install ./trace2-"$version".gem
