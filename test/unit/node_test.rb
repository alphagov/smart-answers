# coding:utf-8

require_relative '../test_helper'

class NodeTest < ActiveSupport::TestCase
  test "Display name taken from name by default" do
    s = SmartAnswer::Node.new(:how_do_you_do?)
    assert_equal "How do you do?", s.display_name
  end
  
  test "Can set the display name" do
    s = SmartAnswer::Node.new(:example) do
      display_name "display"
    end
    
    assert_equal :example, s.name
    assert_equal "display", s.display_name
  end
end