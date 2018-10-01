ENV["RAILS_ENV"] = "test"
require File.expand_path('../../../config/environment', __FILE__)

FLOW_REGISTRY_OPTIONS[:preload_flows] = false

require 'rails/test_help'

require 'webmock'
WebMock.enable!
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../support/fixture_methods'
require_relative '../support/world_location_stubbing_methods'

require 'gds_api/test_helpers/imminence'

require 'mocha/api'

require 'slimmer/test'

class SmartAnswersRegressionTest < ActionController::TestCase
  i_suck_and_my_tests_are_order_dependent!
  RUN_ME_LAST = 'zzzzzzzzzzz run me last'

  class << self
    def setup_has_run!
      @setup_has_run = true
    end

    def setup_has_run?
      @setup_has_run
    end

    def webmock_teardown_hook_installed?
      Minitest::Test.method_defined?(:teardown_with_webmock)
    end

    def custom_teardown_hook_installed?
      Minitest::Test.method_defined?(:teardown_with_customisations)
    end

    def teardown_hooks_installed?
      webmock_teardown_hook_installed? || custom_teardown_hook_installed?
    end
  end

  include GdsApi::TestHelpers::Imminence
  include WebMock::API
  include FixtureMethods
  include Mocha::API
  include WorldLocationStubbingMethods

  tests SmartAnswersController

  SmartAnswerTestHelper.responses_and_expected_results.each do |file|
    filename  = File.basename(file, '.yml')
    flow_name = filename[/(.*)-responses-and-expected-results/, 1]

    smart_answer_helper = SmartAnswerTestHelper.new(flow_name)

    next unless smart_answer_helper.run_regression_tests?

    smart_answer_helper.delete_saved_output_files
    responses_and_expected_results = smart_answer_helper.read_responses_and_expected_results

    context "Smart Answer: #{flow_name}" do
      setup do
        Timecop.freeze(smart_answer_helper.current_time)

        next if self.class.setup_has_run? && !self.class.teardown_hooks_installed?

        mocha_setup

        WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).to_return(body: File.open(fixture_file('bank_holidays.json')))
        Services.content_store.stubs(:content_item).returns({})

        setup_worldwide_locations

        imminence_has_areas_for_postcode("PA3%202SW",  [{ type: 'EUR', name: 'Scotland', country_name: 'Scotland' }])
        imminence_has_areas_for_postcode("B1%201PW",   [{ type: 'EUR', name: 'West Midlands', country_name: 'England' }])
        imminence_has_areas_for_postcode("WC2B%206SE", [{ type: 'EUR', name: 'London', country_name: 'England' }])

        self.class.setup_has_run!
      end

      should "ensure all nodes are being exercised" do
        flow = SmartAnswer::FlowRegistry.instance.find(flow_name)

        nodes_exercised_in_test = responses_and_expected_results.inject([]) do |array, hash|
          current_node = hash[:current_node]
          next_node    = hash[:next_node]
          array << current_node unless array.include?(current_node)
          array << next_node unless array.include?(next_node)
          array
        end

        unexercised_nodes = flow.nodes.map(&:name).map(&:to_sym) - nodes_exercised_in_test
        assert_equal true, unexercised_nodes.empty?, "Not all nodes are being exercised: #{unexercised_nodes}"
      end

      should "render and save the landing page" do
        get :show, params: { id: flow_name, format: 'txt' }
        assert_response :success

        artefact_path = smart_answer_helper.save_output([flow_name], response)
        assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
      end

      should "render and save the first question page" do
        get :show, params: { id: flow_name, started: 'y', format: 'txt' }
        assert_response :success

        artefact_path = smart_answer_helper.save_output(['y'], response)
        assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
      end

      visited_nodes = Set.new
      responses_and_expected_results.each do |responses_and_expected_node|
        next_node     = responses_and_expected_node[:next_node]
        responses     = responses_and_expected_node[:responses]
        question_node = !responses_and_expected_node[:outcome_node]

        next if question_node && visited_nodes.include?(next_node)
        visited_nodes << next_node

        should "render and save output for responses: #{responses.join(', ')}" do
          get :show, params: { id: flow_name, started: 'y', responses: responses.join('/'), format: 'txt' }
          assert_response :success

          artefact_path = smart_answer_helper.save_output(responses, response)

          # Enabling this more than doubles the time it takes to run regression tests
          assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
        end
      end

      should "#{RUN_ME_LAST} and generate the same set of output files" do
        diff_output = `git status --short -- #{smart_answer_helper.path_to_outputs_for_flow}`
        assert diff_output.blank?, "Changes in outcome page artefacts have been detected:\n#{diff_output}\nIf these changes are expected then commit all the changes and re-run the regression test."
      end
    end
  end

private

  def assert_no_output_diff(path_to_output)
    diff_output = `git diff -- "#{path_to_output}"`
    assert diff_output.blank?, diff_output
  end

  def setup_worldwide_locations
    location_slugs = YAML.load(read_fixture_file("worldwide_locations.yml"))
    stub_world_locations(location_slugs, load_fco_organisation_data: true)
  end
end
