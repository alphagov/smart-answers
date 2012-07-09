# encoding: UTF-8

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'simplecov'

SimpleCov.start

require 'minitest/unit'
require 'minitest/autorun'