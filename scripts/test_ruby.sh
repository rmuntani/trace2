#!/bin/bash

rake compile && bundle exec rspec $1
