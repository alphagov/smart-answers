# coding:utf-8

require_relative '../test_helper'

class FlowTest < ActiveSupport::TestCase
  test "Can set the name" do
    s = SmartAnswer::Flow.new do
      name :sweet_or_savoury?
    end
    
    assert_equal :sweet_or_savoury?, s.name
  end
  
  test "Can build outcome nodes" do
    s = SmartAnswer::Flow.new do
      outcome :you_dont_have_a_sweet_tooth
    end
    
    assert_equal 1, s.nodes.size
    assert_equal 1, s.outcomes.size
    assert_equal [:you_dont_have_a_sweet_tooth], s.outcomes.map(&:name)
  end
  
  test "Can build multiple choice question nodes" do
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

  test "Can build date question nodes" do
    s = SmartAnswer::Flow.new do
      date_question :when_is_your_birthday? do
        from { Date.parse('2011-01-01') }
        to { Date.parse('2014-01-01') }
      end
    end
    
    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal Date.parse('2011-01-01')..Date.parse('2014-01-01'), s.questions.first.range
  end
  
  context "sequence of two questions" do
    setup do
      @flow = SmartAnswer::Flow.new do
        multiple_choice :do_you_like_chocolate? do
          option yes: :sweet
          option no: :do_you_like_jam?
        end

        multiple_choice :do_you_like_jam? do
          option yes: :sweet
          option no: :savoury
        end
        outcome :sweet
        outcome :savoury
      end
    end
    
    should "calculate state after a series of responses" do
      assert_equal :do_you_like_chocolate?, @flow.process([]).current_node
      assert_equal :do_you_like_jam?, @flow.process(%w{no}).current_node
      assert_equal :sweet, @flow.process(%w{no yes}).current_node
      assert_equal :sweet, @flow.process(%w{yes}).current_node
      assert_equal :savoury, @flow.process(%w{no no}).current_node
      assert_raises SmartAnswer::InvalidResponse do
        @flow.process(%w{maybe})
      end
    end
  
    should "calculate the path traversed by a series of responses" do
      assert_equal [], @flow.path([])
      assert_equal [:do_you_like_chocolate?], @flow.path(%w{no})
      assert_equal [:do_you_like_chocolate?, :do_you_like_jam?], @flow.path(%w{no yes})
      assert_equal [:do_you_like_chocolate?], @flow.path(%w{yes})
      assert_equal [:do_you_like_chocolate?, :do_you_like_jam?], @flow.path(%w{no no})
      assert_raises SmartAnswer::InvalidResponse do
        @flow.path(%w{maybe})
      end
    end
  end
  
  should "normalize responses" do
    flow = SmartAnswer::Flow.new do
      multiple_choice :colour? do
        option red: :when?
        option blue: :blue
      end
      date_question :when? do
        next_node :blue
      end
      outcome :blue
    end
    
    assert_equal [], flow.normalize_responses([])
    assert_equal ['red'], flow.normalize_responses(['red'])
    assert_equal ['red', '2011-02-01'], flow.normalize_responses(['red', {year: 2011, month: 2, day: 1}])
  end
  
  should "raise an error if next state is not defined" do
    flow = SmartAnswer::Flow.new do
      date_question :when?
    end
    
    assert_raises RuntimeError do
      flow.process(['2011-01-01'])
    end
  end
end