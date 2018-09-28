#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <smart-answer-flow-name>"
  exit
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Please run with a clean git working directory"
  exit
fi

bundle install

bundle exec rails runner script/generate-responses-and-expected-results-for-smart-answer.rb $1

if [[ -n "$(git status --porcelain)" ]]; then
  git add test/data/$1-responses-and-expected-results.yml
  git commit -m "Update expected results for $1"
fi

RUN_REGRESSION_TESTS=$1 ruby test/regression/smart_answers_regression_test.rb

if [[ -n "$(git status --porcelain)" ]]; then
  git add test/artefacts/$1
  git commit -m "Update test artefacts for $1"
fi

RUN_REGRESSION_TESTS=$1 ruby test/regression/smart_answers_regression_test.rb
