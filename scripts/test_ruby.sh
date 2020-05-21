#!/bin/bash

rake compile && bundle exec rspec $@
