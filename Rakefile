#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

SmartAnswers::Application.load_tasks

# Delete the current "default" rake task and redefine it. This allow us to use:
# - `rake test` to only run minitest tests
Rake::Task["default"].clear
task default: %i[test js_test lint security spec]
