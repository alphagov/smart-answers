ENV["RAILS_ENV"] = "test"
require File.expand_path('../../../config/environment', __FILE__)

FLOW_REGISTRY_OPTIONS[:preload_flows] = false

require 'rails/test_help'

require 'webmock'
WebMock.disable_net_connect!(allow_localhost: true)

require_relative '../support/fixture_methods'

require 'gds_api/test_helpers/content_api'
require 'gds_api/test_helpers/worldwide'
require 'gds_api/test_helpers/imminence'

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

  include GdsApi::TestHelpers::ContentApi
  include GdsApi::TestHelpers::Worldwide
  include GdsApi::TestHelpers::Imminence
  include WebMock::API
  include FixtureMethods

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
        next if self.class.setup_has_run? && !self.class.teardown_hooks_installed?
        Timecop.freeze(Date.parse('2015-01-01'))
        stub_content_api_default_artefact
        WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).to_return(body: File.open(fixture_file('bank_holidays.json')))

        setup_worldwide_locations

        imminence_has_areas_for_postcode("WC2B%206SE", [])
        imminence_has_areas_for_postcode("B1%201PW", [{ slug: "birmingham-city-council" }])

        self.class.setup_has_run!
      end

      should "have up to date checksum data" do
        message = []
        message << "Expected #{smart_answer_helper.files_checksum_path} to exist and to contain up to date data"
        message << "Use the generate-checksums-for-smart-answer script to update it"
        assert_equal false, smart_answer_helper.files_checksum_data_needs_updating?, message.join('. ')
      end

      should "ensure all nodes are being exercised" do
        flow = begin
          SmartAnswer::FlowRegistry.instance.find(flow_name)
        rescue SmartAnswer::FlowRegistry::NotFound
          SmartdownAdapter::Registry.instance.find(flow_name)
        end

        nodes_exercised_in_test = responses_and_expected_results.inject([]) do |array, responses_and_expected_results|
          current_node = responses_and_expected_results[:current_node]
          next_node    = responses_and_expected_results[:next_node]
          array << current_node unless array.include?(current_node)
          array << next_node unless array.include?(next_node)
          array
        end

        if flow.respond_to?(:question_pages)
          nodes = (flow.question_pages.flat_map(&:questions) + flow.outcomes)
        else
          nodes = flow.nodes
        end
        unexercised_nodes = nodes.map(&:name).map(&:to_sym) - nodes_exercised_in_test
        assert_equal true, unexercised_nodes.empty?, "Not all nodes are being exercised: #{unexercised_nodes.sort}"
      end

      should "render and save the landing page" do
        get :show, id: flow_name, format: 'txt'

        artefact_path = smart_answer_helper.save_output([flow_name], response)
        assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
      end

      should "render and save the first question page" do
        get :show, id: flow_name, started: 'y', format: 'html'

        artefact_path = smart_answer_helper.save_output(['y'], response, extension: 'html')
        assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
      end

      visited_nodes = Set.new
      responses_and_expected_results.each do |responses_and_expected_node|
        next_node    = responses_and_expected_node[:next_node]
        responses    = responses_and_expected_node[:responses]
        outcome_node = responses_and_expected_node[:outcome_node]

        if !visited_nodes.include?(next_node) || outcome_node
          visited_nodes << next_node
          should "render and save output for responses: #{responses.join(', ')}" do
            format = outcome_node ? 'txt' : 'html'
            get :show, id: flow_name, started: 'y', responses: responses.join('/'), format: format

            artefact_path = smart_answer_helper.save_output(responses, response, extension: format)

            # Enabling this more than doubles the time it takes to run regression tests
            assert_no_output_diff artefact_path if ENV['ASSERT_EACH_ARTEFACT'].present?
          end
        end
      end

      should "#{RUN_ME_LAST} and generate the same set of output files" do
        diff_output = `git status --short -- #{smart_answer_helper.path_to_outputs_for_flow}`
        assert diff_output.blank?, "Changes in outcome page artefacts have been detected:\n#{diff_output}\nIf these changes are expected then re-generate the checksums, re-run the regression test, and commit all the changes."
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
    worldwide_api_has_locations(location_slugs)
    location_slugs.each do |location|
      path_to_organisations_fixture = fixture_file("worldwide/#{location}_organisations.json")
      if File.exist?(path_to_organisations_fixture)
        json = File.read(path_to_organisations_fixture)
        worldwide_api_has_organisations_for_location(location, json)
      end
    end
  end
end
