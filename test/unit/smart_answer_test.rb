# coding:utf-8

require_relative '../test_helper'

class SmartAnswerTest < ActiveSupport::TestCase
  test "Can set the display name" do
    s = SmartAnswer::Flow.new do
      display_name "Sweet or savoury?"
    end
    
    assert_equal "Sweet or savoury?", s.display_name
  end
  
  test "Can build outcome nodes" do
    s = SmartAnswer::Flow.new do
      outcome :you_dont_have_a_sweet_tooth
    end
    
    assert_equal 1, s.nodes.size
    assert_equal 1, s.outcomes.size
    assert_equal [:you_dont_have_a_sweet_tooth], s.outcomes.map(&:name)
  end
  
  test "Can build question nodes" do
    s = SmartAnswer::Flow.new do
      multiple_choice :do_you_like_chocolate? do
        option :yes => :sweet_tooth
        option :no => :savoury_tooth
      end
      
      outcome :sweet_tooth
      outcome :savoury_tooth
    end
    
    assert_equal 3, s.nodes.size
    assert_equal 2, s.outcomes.size
    assert_equal 1, s.questions.size
  end

  test "Starting state has current_node set to the first question node" do
    s = SmartAnswer::Flow.new do
      multiple_choice :do_you_like_chocolate?
    end
    s.start!
    assert_equal :do_you_like_chocolate?, s.state.current_node
    assert s.state.frozen?
  end
end