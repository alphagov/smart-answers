# encoding: UTF-8
require_relative '../integration_test_helper'
require_relative 'maternity_answer_logic'
require_relative 'smart_answer_test_helper'

class MaternityAnswerTest < ActionDispatch::IntegrationTest
  include SmartAnswerTestHelper
  include MaternityAnswerHelpers
  extend MaternityAnswerLogic
  
  should_implement_materntiy_answer_logic
end

