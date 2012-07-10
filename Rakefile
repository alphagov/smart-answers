#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Speed up test run
ENV["DISABLE_LOGGING_IN_TEST"] = "true"

SmartAnswers::Application.load_tasks
