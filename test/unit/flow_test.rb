require_relative "../test_helper"

class FlowTest < ActiveSupport::TestCase
  test "Can set the name" do
    s = SmartAnswer::Flow.new do
      name "sweet-or-savoury"
    end

    assert_equal "sweet-or-savoury", s.name
  end

  test "can set to use session" do
    smart_answer = SmartAnswer::Flow.new do
      use_session true
    end

    assert smart_answer.use_session?
  end

  test "can set to use session with string" do
    smart_answer = SmartAnswer::Flow.new do
      use_session "yes"
    end

    assert smart_answer.use_session?
  end

  test "can set not to use session" do
    smart_answer = SmartAnswer::Flow.new do
      use_session "false"
    end

    assert_not smart_answer.use_session?
  end

  test "defaults to not use session" do
    smart_answer = SmartAnswer::Flow.new

    assert_not smart_answer.use_session?
  end

  test "cannot set a flag to use the escape button if the use session flag is not also set" do
    smart_answer = SmartAnswer::Flow.new do
      use_session false
      use_escape_button true
    end

    assert_raises SmartAnswer::Flow::NonSessionBasedFlow do
      smart_answer.use_escape_button?
    end
  end

  test "can set a flag to use the escape button when the use session flag is also set" do
    smart_answer = SmartAnswer::Flow.new do
      use_session true
      use_escape_button true
    end

    assert smart_answer.use_escape_button?
  end

  test "can set a flag to use the escape button with a string" do
    smart_answer = SmartAnswer::Flow.new do
      use_session true
      use_escape_button "yes"
    end

    assert smart_answer.use_escape_button?
  end

  test "can set a flag not to use the escape button with a string" do
    smart_answer = SmartAnswer::Flow.new do
      use_session true
      use_escape_button "false"
    end

    assert_not smart_answer.use_escape_button?
  end

  test "defaults to not use the escape button" do
    smart_answer = SmartAnswer::Flow.new do
      use_session true
    end

    assert_not smart_answer.use_escape_button?
  end

  test "can set flag to hide previous answers on results page" do
    smart_answer = SmartAnswer::Flow.new do
      hide_previous_answers_on_results_page true
    end

    assert smart_answer.hide_previous_answers_on_results_page?
  end

  test "can set flag to hide previous answers on results pagewith string" do
    smart_answer = SmartAnswer::Flow.new do
      hide_previous_answers_on_results_page "yes"
    end

    assert smart_answer.hide_previous_answers_on_results_page?
  end

  test "can set flag not to hide previous answers on results page" do
    smart_answer = SmartAnswer::Flow.new do
      hide_previous_answers_on_results_page "false"
    end

    assert_not smart_answer.hide_previous_answers_on_results_page?
  end

  test "defaults to show previous answers on results page" do
    smart_answer = SmartAnswer::Flow.new

    assert_not smart_answer.hide_previous_answers_on_results_page?
  end

  test "Can set button text" do
    text = "continue"
    smart_answer = SmartAnswer::Flow.new do
      button_text text
    end

    assert_equal text, smart_answer.button_text
  end

  test "Uses default when not set button text" do
    smart_answer = SmartAnswer::Flow.new

    assert_equal "Next step", smart_answer.button_text
  end

  test "Can set the start page content_id" do
    s = SmartAnswer::Flow.new do
      start_page_content_id "587920ff-b854-4adb-9334-451b45652467"
    end

    assert_equal "587920ff-b854-4adb-9334-451b45652467", s.start_page_content_id
  end

  test "Can set the flow content_id" do
    s = SmartAnswer::Flow.new do
      flow_content_id "587920ff-b854-4adb-9334-451b45652467"
    end

    assert_equal "587920ff-b854-4adb-9334-451b45652467", s.flow_content_id
  end

  test "Defaults the external_related_links to nil" do
    s = SmartAnswer::Flow.new

    assert_nil s.external_related_links
  end

  test "Can set the external_related_links" do
    links = [
      { title: "Book appointment", url: "https://www.booking-an-appointment.gov.uk" },
      { title: "Buy stamps", url: "https://www.stamps.uk" },
    ]
    s = SmartAnswer::Flow.new do
      external_related_links links
    end

    assert_equal links, s.external_related_links
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
      name "flow-name"
      outcome :outcome_name
    end

    assert_equal 1, flow.outcomes.size
    assert flow.outcomes.first.template_directory.to_s.end_with?("flow-name")
  end

  test "Can build multiple choice question nodes" do
    s = SmartAnswer::Flow.new do
      radio :do_you_like_chocolate? do
        option :yes
        option :no
        next_node do |response|
          case response
          when "yes" then outcome :sweet_tooth
          when "no" then outcome :savoury_tooth
          end
        end
      end

      outcome :sweet_tooth
      outcome :savoury_tooth
    end

    assert_equal 3, s.nodes.size
    assert_equal 2, s.outcomes.size
    assert_equal 1, s.questions.size
  end

  test "Can build country select question nodes" do
    stub_world_locations(%w[afghanistan])

    s = SmartAnswer::Flow.new do
      country_select :which_country?
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "afghanistan", s.questions.first.country_list.first.slug
  end

  test "Can build date question nodes" do
    s = SmartAnswer::Flow.new do
      date_question :when_is_your_birthday? do
        from { Date.parse("2011-01-01") }
        to { Date.parse("2014-01-01") }
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal Date.parse("2011-01-01")..Date.parse("2014-01-01"), s.questions.first.range
  end

  test "Can build value question nodes" do
    s = SmartAnswer::Flow.new do
      value_question :what_colour_are_the_bottles? do
        on_response do |response|
          self.bottle_colour = response
        end
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal :what_colour_are_the_bottles?, s.questions.first.name
  end

  test "Can build value question nodes with parse option specified" do
    s = SmartAnswer::Flow.new do
      value_question :how_many_green_bottles?, parse: Integer do
        on_response do |response|
          self.num_bottles = response
        end
      end
    end

    assert_equal 1, s.nodes.size
    assert_equal 1, s.questions.size
  end

  test "Can build money question nodes" do
    s = SmartAnswer::Flow.new do
      money_question :how_much? do
        on_response do |response|
          self.price = response
        end
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
        next_node { outcome :done }
      end
      outcome :done
    end

    assert_equal 2, s.nodes.size
    assert_equal 1, s.questions.size
    assert_equal "SmartAnswer::Question::Checkbox", s.questions.first.class.name
  end

  test "Can build postcode question nodes" do
    flow = SmartAnswer::Flow.new { postcode_question :postcode? }

    assert_equal 1, flow.questions.size
    question = flow.questions.first
    assert_equal :postcode?, question.name
    assert_instance_of SmartAnswer::Question::Postcode, question
  end

  test "should have a need content ID" do
    s = SmartAnswer::Flow.new do
      satisfies_need "dccab509-bd3b-4f92-9af6-30f88485ac41"
    end

    assert_equal "dccab509-bd3b-4f92-9af6-30f88485ac41", s.need_content_id
  end

  test "should default to a draft status" do
    s = SmartAnswer::Flow.new {}

    assert_equal :draft, s.status
  end

  test "supports setting a status" do
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
        radio :do_you_like_chocolate? do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :sweet
            when "no" then question :do_you_like_jam?
            end
          end
        end

        radio :do_you_like_jam? do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :sweet
            when "no" then outcome :savoury
            end
          end
        end
        outcome :sweet
        outcome :savoury
      end
    end

    should "calculate state after a series of responses" do
      assert_equal :do_you_like_chocolate?, @flow.process([]).current_node
      assert_equal :do_you_like_jam?, @flow.process(%w[no]).current_node
      assert_equal :sweet, @flow.process(%w[no yes]).current_node
      assert_equal :sweet, @flow.process(%w[yes]).current_node
      assert_equal :savoury, @flow.process(%w[no no]).current_node
    end

    context "a question raises an error" do
      setup do
        @error_message = "Sorry, that's not valid"
        @flow.node(:do_you_like_jam?)
          .stubs(:parse_input)
          .with("bad")
          .raises(SmartAnswer::BaseStateTransitionError.new(@error_message))
      end

      should "skip a transation and set error flag" do
        assert_equal :do_you_like_jam?, @flow.process(%w[no bad]).current_node
        assert_equal @error_message, @flow.process(%w[no bad]).error
      end

      should "not process any further input after error" do
        @flow.node(:do_you_like_jam?)
          .expects(:parse_input)
          .with("yes")
          .never
        assert_equal :do_you_like_jam?, @flow.process(%w[no bad yes yes]).current_node
      end

      should "truncate path after error" do
        assert_equal [:do_you_like_chocolate?], @flow.path(%w[no bad])
      end
    end

    context "a question raises a logged error" do
      setup do
        @error_message = "Sorry, that's not valid"
        @log_message = "Logged message"
        @error = SmartAnswer::LoggedError.new(@error_message, @log_message)
        @flow.node(:do_you_like_jam?)
          .stubs(:parse_input)
          .with("bad")
          .raises(@error)
      end

      should "notify Sentry" do
        GovukError.expects(:notify).with(@error)
        @flow.process(%w[no bad])
      end
    end

    should "calculate the path traversed by a series of responses" do
      assert_equal [], @flow.path([])
      assert_equal [:do_you_like_chocolate?], @flow.path(%w[no])
      assert_equal %i[do_you_like_chocolate? do_you_like_jam?], @flow.path(%w[no yes])
      assert_equal [:do_you_like_chocolate?], @flow.path(%w[yes])
      assert_equal %i[do_you_like_chocolate? do_you_like_jam?], @flow.path(%w[no no])
    end
  end

  context "sequence of two questions with resolve state" do
    setup do
      @chocolate = "do_you_like_chocolate?"
      @jam = "do_you_like_jam?"

      @flow = SmartAnswer::Flow.new do
        radio :do_you_like_chocolate? do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :sweet
            when "no" then question :do_you_like_jam?
            end
          end
        end

        radio :do_you_like_jam? do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :sweet
            when "no" then outcome :savoury
            end
          end
        end
        outcome :sweet
        outcome :savoury
      end
    end

    should "calculate state at start of flow" do
      assert_equal :do_you_like_chocolate?, @flow.resolve_state({}, @chocolate).current_node
    end

    should "return sweet if like chocolate" do
      assert_equal :sweet, @flow.resolve_state({ @chocolate => "yes" }, :sweet).current_node
    end

    should "return jam question when don't like chocolate" do
      assert_equal :do_you_like_jam?, @flow.resolve_state({ @chocolate => "no" }, @jam).current_node
    end

    should "return sweet outcome if don't like chocolate but like jam" do
      assert_equal :sweet, @flow.resolve_state({ @chocolate => "no", @jam => "yes" }, :sweet).current_node
    end

    should "return savoury if don't like chocolate nor jam" do
      assert_equal :savoury, @flow.resolve_state({ @chocolate => "no", @jam => "no" }, :savoury).current_node
    end

    should "return sweet if on savoury but answer changed to liking chocolate" do
      assert_equal :sweet, @flow.resolve_state({ @chocolate => "yes", @jam => "no" }, :savoury).current_node
    end
  end

  context "resolve state" do
    setup do
      @flow = SmartAnswer::Flow.new do
        radio :x do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :y
            when "no" then question :a
            end
          end
        end

        radio :y do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :a
            when "no" then outcome :b
            end
          end
        end
        outcome :a
        outcome :b
      end
    end

    should "resolve requested node with errors if response missing" do
      state = @flow.resolve_state({ "x" => nil }, "x")
      assert_equal :x, state.current_node
      assert state.error.present?
    end

    should "resolve requested node with errors if response invalid" do
      state = @flow.resolve_state({ "x" => "invalid" }, "x")
      assert_equal :x, state.current_node
      assert state.error.present?
    end

    should "resolve requested node if not previously visited" do
      state = @flow.resolve_state({}, "x")
      assert_equal :x, state.current_node
      assert state.error.blank?
    end

    should "resolve requested node if response valid" do
      state = @flow.resolve_state({ "x" => "yes" }, "x")
      assert_equal :x, state.current_node
      assert state.error.blank?
    end

    should "resolve previous node with errors if response missing for previous node" do
      state = @flow.resolve_state({ "x" => nil }, "y")
      assert_equal :x, state.current_node
      assert state.error.present?
    end

    should "resolve previous node with errors if response invalid for previous node" do
      state = @flow.resolve_state({ "x" => "invalid" }, "y")
      assert_equal :x, state.current_node
      assert state.error.present?
    end

    should "resolve previous node if previous node not visited" do
      state = @flow.resolve_state({}, "y")
      assert_equal :x, state.current_node
      assert state.error.blank?
    end

    should "resolve node if previous node has valid response" do
      state = @flow.resolve_state({ "x" => "yes" }, "y")
      assert_equal :y, state.current_node
      assert state.error.blank?
    end

    should "resolve outcome node if all valid responses given" do
      state = @flow.resolve_state({ "x" => "yes", "y" => "yes" }, "a")
      assert_equal :a, state.current_node
      assert state.error.blank?
    end

    should "resolve correct outcome node for given valid responses" do
      state = @flow.resolve_state({ "x" => "yes", "y" => "yes" }, "b")
      assert_equal :a, state.current_node
      assert state.error.blank?
    end

    should "resolve correct outcome node even f" do
      state = @flow.resolve_state({ "x" => "yes", "y" => "yes" }, "b")
      assert_equal :a, state.current_node
      assert state.error.blank?
    end
  end

  should "normalize responses" do
    flow = SmartAnswer::Flow.new do
      radio :colour? do
        option :red
        option :blue

        next_node do |response|
          case response
          when "red" then question :when?
          when "blue" then outcome :blue
          end
        end
      end
      date_question :when? do
        next_node { outcome :blue }
      end
      outcome :blue
    end

    assert_equal [], flow.process([]).responses
    assert_equal %w[red], flow.process(%w[red]).responses
    assert_equal ["red", Date.parse("2011-02-01")], flow.process(["red", { year: 2011, month: 2, day: 1 }]).responses
  end

  should "evaluate on_response block" do
    flow = SmartAnswer::Flow.new do
      money_question :how_much? do
        on_response do |response|
          self.price = response
        end
        next_node { outcome :done }
      end
      outcome :done
    end

    state = flow.process(%w[1])
    assert_equal SmartAnswer::Money.new("1"), state.price
  end

  should "raise an error if next state is not defined" do
    flow = SmartAnswer::Flow.new do
      date_question :when?
    end

    assert_raises SmartAnswer::Question::Base::NextNodeUndefined do
      flow.process(%w[2011-01-01])
    end
  end

  context "when another flow is appended to this one" do
    setup do
      other_flow = SmartAnswer::Flow.new do
        outcome :another_outcome
      end
      @flow = SmartAnswer::Flow.new do
        value_question :question?
        outcome :outcome
        append(other_flow)
      end
    end

    should "have nodes from other flow after nodes in this flow" do
      assert_equal %i[question? outcome another_outcome], @flow.nodes.map(&:name)
    end

    should "set flow on all nodes from other flow" do
      assert(@flow.nodes.all? { |node| node.flow == @flow })
    end
  end
end
