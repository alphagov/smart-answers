# encoding: UTF-8
require_relative '../test_helper'

class SmartAnswersControllerTest < ActionController::TestCase
  def setup
    @flow = SmartAnswer::Flow.new do
      name :sample
      
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
    @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
  end
  
  context "GET /" do
    should "respond with 404 if not found" do
      @registry = stub("Flow registry")
      @registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
      @controller.stubs(:flow_registry).returns(@registry)
      get :show, id: 'sample'
      assert_response :missing
    end
    
    should "display landing page if no questions answered yet" do
      get :show, id: 'sample'
      assert_select "h1", /#{@flow.name.to_s.humanize}/
    end
    
    should "not have noindex tag on landing page" do
      get :show, id: 'sample'
      assert_select "meta[name=robots][content=noindex]", count: 0
    end

    should "display first question after starting" do
      get :show, id: 'sample', started: 'y'
      assert_select ".step.current h2", /1\s+Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end
    
    should "have meta robots noindex on question pages" do
      get :show, id: 'sample', started: 'y'
      assert_select "head meta[name=robots][content=noindex]"
    end
    
    context "value question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          name :sample
          value_question :how_many_green_bottles? do
            next_node :done
          end
          
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end
      
      should "display question" do
        get :show, id: 'sample', started: 'y'
        assert_select ".step.current h2", /1\s+How many green bottles\?/
        assert_select "input[type=text][name=response]"
      end
      
      should "accept question input and redirect to canonical url" do
        get :show, id: 'sample', started: 'y', response: "10"
        assert_redirected_to '/sample/y/10'
      end
      
      should "display collapsed question, and format number" do
        get :show, id: 'sample', started: 'y', responses: ["12345"]
        assert_select ".done", /1\s+How many green bottles\?\s+12,345/
      end
    end
    
    context "money question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          money_question :how_much? do
            next_node :done
          end
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end
      
      should "display question" do
        get :show, id: 'sample', started: 'y'
        assert_select ".step.current h2", /1\s+How much\?/
        assert_select "input[type=text][name=response]"
      end

      should "show a validation error if invalid input" do
        get :show, id: 'sample', started: 'y', response: 'bad_number'
        assert_select ".step.current h2", /1\s+How much\?/
        assert_select "body", /Please answer this question/
      end

    end
    
    context "salary question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          name :sample
          
          salary_question(:how_much?) { next_node :done }
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end
      
      should "display question" do
        get :show, id: 'sample', started: 'y'
        assert_select ".step.current h2", /1\s+How much\?/
        assert_select "input[type=text][name='response[amount]']"
        assert_select "select[name='response[period]']"
      end

      context "error message overridden in translation file" do
        setup do
          @old_load_path = I18n.config.load_path.dup
          @example_translation_file = 
            File.expand_path('../../fixtures/smart_answers_controller_test/sample.yml', __FILE__)
          I18n.config.load_path.unshift(@example_translation_file)
          I18n.reload!
        end

        teardown do
          I18n.config.load_path = @old_load_path
          I18n.reload!
        end
        
        should "show a validation error if invalid amount" do
          get :show, id: 'sample', started: 'y', response: {amount: 'bad_number'}
          assert_select ".step.current h2", /1\s+How much\?/
          assert_select ".error", /No, really, how much\?/
        end
      end

      context "error message not overridden in translation file" do
        should "show a generic message" do
          get :show, id: 'sample', started: 'y', response: {amount: 'bad_number'}
          assert_select ".step.current h2", /1\s+How much\?/
          assert_select ".error", /Please answer this question./
        end
      end

      should "show a validation error if invalid period" do
        get :show, id: 'sample', started: 'y', response: {amount: '1', period: 'bad_period'}
        assert_select ".step.current h2", /1\s+How much\?/
        assert_select ".error", /Please answer this question./
      end

      should "accept responses as GET params and redirect to canonical url" do
        get :show, id: 'sample', started: 'y', response: {amount: '1', period: 'month'}
        assert_redirected_to '/sample/y/1.0-month'
      end

      context "a response has been accepted" do
        setup { get :show, id: 'sample', started: 'y', responses: ["1.0-month"] }

        should "show response summary" do
          assert_select ".done", /1\s+How much\?\s+£1 per month/
        end
      end
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
    
    context "format=fragment" do
      should "render content without layout" do
        get :show, id: 'sample', started: 'y', responses: ["no"], format: "json"
        data = JSON.parse(response.body)
        assert_equal '/sample/y/no', data['url']
        doc = Nokogiri::HTML(data['html_fragment'])
        assert_match /#{@flow.name.to_s.humanize}/, doc.xpath('//h1').first.to_s
        assert_equal 0, doc.xpath('//head').size, "Should not have layout"
        assert_equal '/sample/y/no', doc.xpath('//form').first.attributes['action'].to_s
        assert_equal @flow.node(:do_you_like_jam?).name.to_s.humanize, data['title']
      end
      
      should "redirect to canonical url and retain format=fragment" do
        get :show, id: 'sample', started: 'y', response: "yes", format: "json"
        assert_redirected_to '/sample/y/yes.json'
      end
    end
  end
end
