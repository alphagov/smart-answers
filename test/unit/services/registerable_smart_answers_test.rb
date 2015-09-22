require 'test_helper'

class RegisterableSmartAnswersTest < ActiveSupport::TestCase
  def test_unique_smart_answers
    registerables = RegisterableSmartAnswers.new.unique_registerables

    assert registerables.size > 30
  end
end
