require_relative '../test_helper'

class SmartAnswersControllerTest < ActionController::TestCase
  def setup
    @flow = SmartAnswer::Flow.new do
      display_name "What's your favourite food?"

      multiple_choice :do_you_like_chocolate? do
        option :yes => :you_have_a_sweet_tooth
        option :no => :do_you_like_jam?
      end
      
      multiple_choice :do_you_like_jam? do
        option :yes => :you_have_a_sweet_tooth
        option :no => :you_have_a_savoury_tooth
      end
      
      outcome :you_have_a_savoury_tooth
      outcome :you_have_a_sweet_tooth
    end
    @controller.stubs(:smart_answer).returns(@flow)
  end
  
  context "GET /" do
    should "display landing page if no questions answered yet" do
      get :show, id: 'sample'
      assert_select "h1", @flow.display_name
    end

    should "display first question after starting" do
      get :show, id: 'sample', started: 'y'
      assert_select ".step.current h3", /1\s+Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end

    should "accept responses as GET params and redirect to canonical url" do
      get :show, id: 'sample', started: 'y', response: "yes"
      assert_redirected_to '/sample/y/yes'
    end

    context "a response has been accepted" do
      setup { get :show, id: 'sample', started: 'y', responses: ["no"] }
      
      should "show response summary" do
        assert_select ".done", /1\s+Do you like chocolate\?\s+no/
      end

      should "show the next question" do
        assert_select ".current", /2\s+Do you like jam\?/
      end
      
      should "link back to change the response" do
        assert_select ".done a", /Change this/ do |link_nodes|
          assert_equal '/sample/y?', link_nodes.first['href']
        end
      end
      
    end

  end
end