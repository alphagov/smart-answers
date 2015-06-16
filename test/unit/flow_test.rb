# coding:utf-8

require_relative '../test_helper'

class FlowTest < ActiveSupport::TestCase
  test "Can set the name" do
    s = SmartAnswer::Flow.new do
      name "sweet-or-savoury"
    end

    assert_equal "sweet-or-savoury", s.name
  end

  test "Can build outcome nodes" do
    s = SmartAnswer::Flow.new do
      outcome :you_dont_have_a_sweet_tooth
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.outcomes.size
    assert_equal [:you_dont_have_a_sweet_tooth], s.outcomes.map(&:name)
  end

  test "Can build outcomes where the whole flow uses ERB templates" do
    flow = SmartAnswer::Flow.new do
      name 'flow-name'
      use_outcome_templates
      outcome :outcome_name
    end

    assert_equal 1, flow.outcomes.size
    assert_equal true, flow.outcomes.first.use_template?
    assert flow.outcomes.first.template_directory.to_s.end_with?('flow-name')
  end

  test "Can build single outcomes that use ERB templates" do
    flow = SmartAnswer::Flow.new do
      name 'flow-name'
      outcome :outcome_with_erb_template, use_outcome_templates: true
      outcome :outcome_without_erb_template, use_outcome_templates: false
    end

    assert_equal 2, flow.outcomes.size

    assert_equal true, flow.outcomes.first.use_template?
    assert flow.outcomes.first.template_directory.to_s.end_with?('flow-name')

    assert_equal false, flow.outcomes.last.use_template?
  end

  test "Can build multiple choice question nodes" do
    s = SmartAnswer::Flow.new do
      multiple_choice :do_you_like_chocolate? do
        option yes: :sweet_tooth
 option no: :savoury_tooth
      end

      outcome :sweet_tooth
      outcome :savoury_tooth
    end

    assert_equal 3, s.nodes.size
    assert_equal 2, s.outcomes.size
    assert_equal 1, s.questions.size
  end

  test "Can build country select question nodes" do
    s = SmartAnswer::Flow.new do
      country_select :which_country?, use_legacy_data: true
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "afghanistan", s.questions.first.country_list.first.slug
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

  test "Can build value question nodes" do
    s = SmartAnswer::Flow.new do
      value_question :what_colour_are_the_bottles? do
        save_input_as :bottle_colour
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :what_colour_are_the_bottles?, s.questions.first.name
  end

  test "Can build value question nodes with parse option specified" do
    s = SmartAnswer::Flow.new do
      value_question :how_many_green_bottles?, parse: Integer do
        save_input_as :num_bottles
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
  end

  test "Can build money question nodes" do
    s = SmartAnswer::Flow.new do
      money_question :how_much? do
        save_input_as :price
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :how_much?, s.questions.first.name
  end

  test "Can build salary question nodes" do
    s = SmartAnswer::Flow.new { salary_question :how_much? }
    assert_equal [:how_much?], s.questions.map(&:name)
  end

  test "Can build checkbox question nodes" do
    s = SmartAnswer::Flow.new do
      checkbox_question :choose_some do
        option :foo
        next_node :done
      end
      outcome :done
    end

    assert_equal 2, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "SmartAnswer::Question::Checkbox", s.questions.first.class.name
  end

  test "should have a need ID" do
    s = SmartAnswer::Flow.new do
      satisfies_need 1337
    end

    assert_equal 1337, s.need_id
  end

  test "should not be draft" do
    s = SmartAnswer::Flow.new {}

    refute s.draft?
  end

  test "should be draft if status is draft" do
    s = SmartAnswer::Flow.new do
      status :draft
    end

    assert s.draft?
  end

  test "should not be transition" do
    s = SmartAnswer::Flow.new {}

    refute s.transition?
  end

  test "should be transition if status is transition" do
    s = SmartAnswer::Flow.new do
      status :transition
    end

    assert s.transition?
  end

  test "should have a status" do
    s = SmartAnswer::Flow.new do
      status :published
    end

    assert_equal :published, s.status
  end

  test "should throw an exception if invalid status provided" do
    assert_raise SmartAnswer::Flow::InvalidStatus do
      SmartAnswer::Flow.new do
        status :bin
      end
    end
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
    end

    context "a question raises an error" do
      setup do
        @error_message = "Sorry, that's not valid"
        @flow.node(:do_you_like_jam?)
          .stubs(:parse_input)
          .with('bad')
          .raises(SmartAnswer::InvalidResponse.new(@error_message))
      end

      should "skip a transation and set error flag" do
        assert_equal :do_you_like_jam?, @flow.process(%w{no bad}).current_node
        assert_equal @error_message, @flow.process(%w{no bad}).error
      end

      should "not process any further input after error" do
        @flow.node(:do_you_like_jam?)
          .expects(:parse_input)
          .with('yes')
          .never
        assert_equal :do_you_like_jam?, @flow.process(%w{no bad yes yes}).current_node
      end

      should "truncate path after error" do
        assert_equal [:do_you_like_chocolate?], @flow.path(%w{no bad})
      end
    end

    should "calculate the path traversed by a series of responses" do
      assert_equal [], @flow.path([])
      assert_equal [:do_you_like_chocolate?], @flow.path(%w{no})
      assert_equal [:do_you_like_chocolate?, :do_you_like_jam?], @flow.path(%w{no yes})
      assert_equal [:do_you_like_chocolate?], @flow.path(%w{yes})
      assert_equal [:do_you_like_chocolate?, :do_you_like_jam?], @flow.path(%w{no no})
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

    assert_equal [], flow.process([]).responses
    assert_equal ['red'], flow.process(['red']).responses
    assert_equal ['red', Date.parse('2011-02-01')], flow.process(['red', {year: 2011, month: 2, day: 1}]).responses
  end

  should "perform calculations on saved inputs" do
    flow = SmartAnswer::Flow.new do
      money_question :how_much? do
        next_node :done
        save_input_as :price
        calculate :double do
          price.value * 2
        end
      end
      outcome :done
    end

    state = flow.process(["1"])
    assert_equal SmartAnswer::Money.new('1'), state.price
    assert_equal 2.0, state.double
  end

  should "perform precalculations on saved inputs" do
    flow = SmartAnswer::Flow.new do
      money_question :how_much? do
        next_node :done
        save_input_as :price
      end
      outcome :done do
        precalculate :double do
          price.value * 2
        end
      end
    end

    state = flow.process(["1"])
    assert_equal SmartAnswer::Money.new('1'), state.price
    assert_equal 2.0, state.double
  end

  should "raise an error if next state is not defined" do
    flow = SmartAnswer::Flow.new do
      date_question :when?
    end

    assert_raises SmartAnswer::Question::Base::NextNodeUndefined do
      flow.process(['2011-01-01'])
    end
  end

  test "should allow using shared logic" do
    File.stubs(:read).with(Rails.root.join('lib', 'smart_answer_flows', 'shared_logic', "test_flow_logic.rb")).returns(<<-EOT)
multiple_choice :do_you_like_chocolate? do
  option :yes => :sweet_tooth
  option :no => :savoury_tooth
end

outcome :sweet_tooth
outcome :savoury_tooth
    EOT

    s = SmartAnswer::Flow.new do
      use_shared_logic 'test_flow_logic'
    end

    assert_equal 3, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :do_you_like_chocolate?, s.questions.first.name
    assert_equal 2, s.outcomes.size
    assert_equal [:sweet_tooth, :savoury_tooth], s.outcomes.map(&:name)
  end
end
