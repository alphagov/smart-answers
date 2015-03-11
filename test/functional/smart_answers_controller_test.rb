# encoding: UTF-8
require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerTest < ActionController::TestCase
  include I18nTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    @flow = SmartAnswer::Flow.new do
      name :sample

      satisfies_need 1337

      multiple_choice :do_you_like_chocolate? do
        option yes: :you_have_a_sweet_tooth
        option no: :do_you_like_jam?
      end

      multiple_choice :do_you_like_jam? do
        option yes: :you_have_a_sweet_tooth
        option no: :you_have_a_savoury_tooth
      end

      outcome :you_have_a_savoury_tooth
      outcome :you_have_a_sweet_tooth
    end
    @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
  end

  def submit_response(response = nil, other_params = {})
    params = {
      id: 'sample',
      started: 'y',
      next: "Next Question"
    }
    params[:response] = response if response
    get :show, params.merge(other_params)
  end

  def submit_json_response(response = nil, other_params = {})
    params = {
      id: 'sample',
      started: 'y',
      format: "json",
      next: "1"
    }
    params[:response] = response if response
    get :show, params.merge(other_params)
  end

  context "GET /<slug>" do
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

    should "have cache headers set to 30 mins" do
      get :show, id: "sample"
      assert_equal "max-age=1800, public", @response.header["Cache-Control"]
    end

    context "without a valid artefact" do
      setup do
        SmartAnswerPresenter.any_instance.stubs(:artefact).returns({})
      end

      should "still return a success response" do
        get :show, id: "sample"
        assert response.ok?
      end

      should "have cache headers set to 5 seconds" do
        get :show, id: "sample"
        assert_equal "max-age=5, public", @response.header["Cache-Control"]
      end
    end

    context "meta description in translation file" do
      should "be shown" do
        using_translation_file(fixture_file('smart_answers_controller_test/meta_description.yml')) do
          get :show, id: 'sample'
        end
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal 'This is a test description', meta_tags.first['content']
        end
      end
    end

    should "display first question after starting" do
      get :show, id: 'sample', started: 'y'
      assert_select ".step.current h2", /Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end

    should "show outcome when smart answer is complete so that 'smartanswerOutcome' JS event is fired" do
      get :show, id: 'sample', started: 'y', responses: 'yes'
      assert_select ".outcome"
    end

    should "have meta robots noindex on question pages" do
      get :show, id: 'sample', started: 'y'
      assert_select "head meta[name=robots][content=noindex]"
    end

    should "send the artefact to slimmer" do
      artefact = artefact_for_slug('sample')
      SmartAnswerPresenter.any_instance.stubs(:artefact).returns(artefact)
      @controller.expects(:set_slimmer_artefact).with(artefact)

      get :show, id: 'sample'
    end

    should "503 if content_api times out" do
      SmartAnswerPresenter.any_instance.stubs(:artefact).raises(GdsApi::TimedOutException)

      get :show, id: 'sample'
      assert_equal 503, response.status
    end

    should "send slimmer analytics headers" do
      get :show, id: 'sample'
      assert_equal "smart_answer", @response.headers["X-Slimmer-Format"]
    end

    should "cope with no artefact found" do
      content_api_does_not_have_an_artefact 'sample'
      get :show, id: 'sample'
      assert @response.success?
    end

    context "date question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          name :sample
          date_question :when? do
            next_node :done
          end
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end

      should "display question" do
        get :show, id: 'sample', started: 'y'
        assert_select ".step.current h2", /When\?/
        assert_select "select[name='response[day]']"
        assert_select "select[name='response[month]']"
        assert_select "select[name='response[year]']"
      end

      should "accept question input and redirect to canonical url" do
        submit_response day: "1", month: "1", year: "2011"
        assert_redirected_to '/sample/y/2011-01-01'
      end

      should "not error if passed blank response" do
        submit_response ''
        assert_response :success
      end

      should "not error if passed string response" do
        submit_response 'bob'
        assert_response :success
      end

      context "valid response given" do
        context "format=json" do
          should "give correct canonical url" do
            submit_json_response(day: "01", month: "01", year: "2013")
            assert_redirected_to '/sample/y/2013-01-01.json'
          end

          should "set correct cache control headers" do
            submit_json_response(day: "01", month: "01", year: "2013")
            assert_equal "max-age=1800, public", @response.header["Cache-Control"]
          end
        end
      end

      context "no response given" do
        should "redisplay question" do
          submit_response(day: "", month: "", year: "")
          assert_select ".step.current h2", /When\?/
        end

        should "show an error message" do
          submit_response(day: "", month: "", year: "")
          assert_select ".step.current .error"
        end

        context "format=json" do
          should "give correct canonical url" do
            submit_json_response(day: "", month: "", year: "")
            data = JSON.parse(response.body)
            assert_equal '/sample/y', data['url']
          end

          should "show an error message" do
            submit_json_response(day: "", month: "", year: "")
            data = JSON.parse(response.body)
            doc = Nokogiri::HTML(data['html_fragment'])
            current_step = doc.css('.step.current')
            assert current_step.css('.error').size > 0, "#{current_step.to_s} should contain .error"
          end
        end
      end

      should "display collapsed question, and format number" do
        get :show, id: 'sample', started: 'y', responses: "2011-01-01"
        assert_select ".done-questions", /When\?\s+1 January 2011/
      end
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
        assert_select ".step.current h2", /How many green bottles\?/
        assert_select "input[type=text][name=response]"
      end

      should "accept question input and redirect to canonical url" do
        submit_response "10"
        assert_redirected_to '/sample/y/10'
      end

      should "display collapsed question, and format number" do
        get :show, id: 'sample', started: 'y', responses: "12345"
        assert_select ".done-questions", /How many green bottles\?\s+12,345/
      end

      context "label in translation file" do
        setup do
          using_translation_file(fixture_file('smart_answers_controller_test/label_for_sample_question.yml')) do
            get :show, id: 'sample', started: 'y'
          end
        end
        should "show the label text before the question input" do
          assert_match /Enter a number.*?input.*?name="response".*?/, response.body
          assert_select "label > input[type=text][name=response]"
        end
      end

      context "suffix_label in translation file" do
        setup do
          using_translation_file(fixture_file('smart_answers_controller_test/suffix_label_for_sample_question.yml')) do
            get :show, id: 'sample', started: 'y'
          end
        end

        should "show the label text after the question input" do
          assert_match /input.*?name="response".*?bottles\./, response.body
          assert_select "label > input[type=text][name=response]"
        end
      end
    end

    context "money question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          name :sample
          money_question :how_much? do
            next_node :done
          end
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end

      should "display question" do
        get :show, id: 'sample', started: 'y'
        assert_select ".step.current h2", /How much\?/
        assert_select "input[type=text][name=response]"
      end

      should "show a validation error if invalid input" do
        submit_response "bad_number"
        assert_select ".step.current h2", /How much\?/
        assert_select "body", /Please answer this question/
      end

      context "suffix_label in translation file" do
        setup do
          using_translation_file(fixture_file('smart_answers_controller_test/suffix_label_for_sample_question.yml')) do
            get :show, id: 'sample', started: 'y'
          end
        end

        should "show the label after the question input" do
          assert_select "label > input[type=text][name=response]"
          assert_match /input.*?name="response".*?millions\./, response.body
        end
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
        assert_select ".step.current h2", /How much\?/
        assert_select "input[type=text][name='response[amount]']"
        assert_select "select[name='response[period]']"
      end

      context "error message overridden in translation file" do
        setup do
          using_translation_file(fixture_file('smart_answers_controller_test/error_message_for_how_much.yml')) do
            submit_response amount: "bad_number"
          end
        end

        should "show a validation error if invalid amount" do
          assert_select ".step.current h2", /How much\?/
          assert_select ".error", /No, really, how much\?/
        end
      end

      context "error message not overridden in translation file" do
        should "show a generic message" do
          submit_response amount: "bad_number"
          assert_select ".step.current h2", /How much\?/
          assert_select ".error", /Please answer this question/
        end
      end

      should "show a validation error if invalid period" do
        submit_response amount: "1", period: "bad_period"
        assert_select ".step.current h2", /How much\?/
        assert_select ".error", /Please answer this question/
      end

      should "accept responses as GET params and redirect to canonical url" do
        submit_response amount: "1", period: "month"
        assert_redirected_to '/sample/y/1.0-month'
      end

      context "a response has been accepted" do
        setup { get :show, id: 'sample', started: 'y', responses: "1.0-month" }

        should "show response summary" do
          assert_select ".done-questions", /How much\?\s+£1 per month/
        end

        should "have cache headers set to 30 mins for inner pages" do
          assert_equal "max-age=1800, public", @response.header["Cache-Control"]
        end
      end
    end

    context "multiple choice question" do
      setup do
        @flow = SmartAnswer::Flow.new do
          name :sample
          multiple_choice :what? do
            option cheese: :done
          end
          outcome :done
        end
        @controller.stubs(:flow_registry).returns(stub("Flow registry", find: @flow))
      end

      context "format=json" do
        context "no response given" do
          should "show an error message" do
            submit_json_response(nil)
            data = JSON.parse(response.body)
            doc = Nokogiri::HTML(data['html_fragment'])
            assert doc.css('.error').size > 0, "#{data['html_fragment']} should contain .error"
          end
        end
      end
    end

    should "accept responses as GET params and redirect to canonical url" do
      submit_response "yes"
      assert_redirected_to '/sample/y/yes'
    end

    context "a response has been accepted" do
      setup { get :show, id: 'sample', started: 'y', responses: "no" }

      should "show response summary" do
        assert_select ".done-questions", /Do you like chocolate\?\s+no/
      end

      should "show the next question" do
        assert_select ".current", /Do you like jam\?/
      end

      should "link back to change the response" do
        assert_select ".done-questions a", /Change/ do |link_nodes|
          assert_equal '/sample/y?previous_response=no', link_nodes.first['href']
        end
      end
    end

    context "format=json" do
      should "render content without layout" do
        get :show, id: 'sample', started: 'y', responses: "no", format: "json"
        data = JSON.parse(response.body)
        assert_equal '/sample/y/no', data['url']
        doc = Nokogiri::HTML(data['html_fragment'])
        assert_match /#{@flow.name.to_s.humanize}/, doc.css('h1').first.to_s
        assert_equal 0, doc.css('head').size, "Should not have layout"
        assert_equal '/sample/y/no', doc.css('form').first.attributes['action'].to_s
        assert_equal @flow.node(:do_you_like_jam?).name.to_s.humanize, data['title']
      end
    end

    context "debugging" do
      should "render debug information on the page when enabled" do
        @controller.stubs(:debug?).returns(true)
        get :show, id: 'sample', started: 'y', responses: "no", debug: "1"

        assert_select "pre.debug"
      end

      should "not render debug information on the page when not enabled" do
        @controller.stubs(:debug?).returns(false)
        get :show, id: 'sample', started: 'y', responses: "no", debug: nil

        assert_select "pre.debug", false, "The page should not render debug information"
      end
    end
  end
end
