# coding:utf-8

require_relative '../test_helper'

class NodeTest < ActiveSupport::TestCase
  test "Can set the display name" do
    s = SmartAnswer::Node.new(:example) do
      display_name "display"
    end
    
    assert_equal :example, s.name
    assert_equal "display", s.display_name
  end
end