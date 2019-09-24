require "rails/console/app"

# TODO: Break this class up a bit
class MarriageAbroadOutcomeFlattener
  COUNTRIES_DIR = "lib/smart_answer_flows/marriage-abroad/outcomes/countries".freeze

  include Rails::ConsoleMethods

  def initialize(country, logger: Logger.new(STDOUT))
    @country = country
    @logger = logger

    stubs_etc
  end

  def flatten
    logger.info("Flattening outcomes for #{country}")
    generate_and_add_partials_to_country_files
  end

private

  attr_reader :country, :logger

  def stubs_etc
    Timecop.freeze(current_time)
    Services.content_store = FakeContentStore.new
    ENV["PLEK_SERVICE_WHITEHALL_ADMIN_URI"] = "https://www.gov.uk"
  end

  def generate_and_add_partials_to_country_files
    visited_nodes = Set.new
    titles = {}
    responses_and_expected_results.each do |responses_and_expected_node|
      next_node     = responses_and_expected_node[:next_node]
      responses     = responses_and_expected_node[:responses]
      question_node = !responses_and_expected_node[:outcome_node]

      next unless %w[opposite_sex same_sex].include?(responses.last)
      next if question_node && visited_nodes.include?(next_node)

      visited_nodes << next_node

      responses_path = responses.join("/")

      route = "/#{flow_name}/y/#{responses_path}.txt"
      raise "Failed to load `#{route}`" unless app.get(route) == 200

      body = app.response.body
      template_path = "#{country_outcome_path(responses_path)}.govspeak.erb"

      responses_directory = File.dirname(template_path)
      FileUtils.mkdir_p(responses_directory) unless File.directory?(responses_directory)

      lines = body.split("\n")
      titles[responses.last] = lines.shift
      lines.shift

      File.write(template_path, insert_payment_partials(lines.join("\n")) + "\n")
    end

    File.write("#{country_partials_dir}/_title.govspeak.erb", title_contents(titles))
  end

  # Strips the first two lines of the file (the title).
  # Replaces payment instructions with a shared partial erb snippet.
  # Replaces service fee with a fees table shared partial erb snippet.
  def insert_payment_partials(body)
    replace_fee_table(replace_how_to_pay(body))
  end

  def country_outcome_path(responses_path)
    "#{COUNTRIES_DIR}/#{responses_path}"
      .gsub("same_sex", "_same_sex")
      .gsub("opposite_sex", "_opposite_sex")
  end

  def country_partials_dir
    "#{COUNTRIES_DIR}/#{country}"
  end

  def replace_how_to_pay(text)
    text.gsub(
      /^\^?You can( only)? pay by.*?\n.*?^$/mi,
      <<~HOW_TO_PAY.freeze,
        <%= render partial: 'how_to_pay.govspeak.erb', locals: {calculator: calculator} %>
      HOW_TO_PAY
    )
  end

  def replace_fee_table(text)
    text.gsub(
      /^Service \| Fee\n.*?^$/mi,
      <<~FEE_TABLE.freeze,
        <%= render partial: 'consular_fees_table_items.govspeak.erb',
            collection: calculator.services,
            as: :service,
            locals: { calculator: calculator } %>
      FEE_TABLE
    )
  end

  def title_contents(titles)
    <<~TITLE.freeze
      <% if calculator.partner_is_same_sex? %>
        #{titles['same_sex']}
      <% else %>
        #{titles['opposite_sex']}
      <% end %>
    TITLE
  end

  def questions_and_responses
    @questions_and_responses ||= flow.questions.each_with_object({}) do |question, hash|
      if question.is_a?(SmartAnswer::Question::CountrySelect)
        hash[question.name] = question.options.map(&:slug)
      elsif question.respond_to?(:options)
        hash[question.name] = question.options
      else
        question_node = flow.node(question)
        question_text = QuestionPresenter.new(question_node, {}, helpers: [MethodMissingHelper]).title

        raise UnknownResponse.new("Unknown response to this question: `#{question.name}`: #{question_text}")
      end
    end
  end

  def flow_name
    "marriage-abroad"
  end

  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(flow_name)
  end

  def flow_with_country_selected
    @flow_with_country_selected ||= flow.process([@country])
  end

  def responses_and_expected_results
    @responses_and_expected_results ||= recursively_answer_questions(flow_with_country_selected, [])
  end

  def recursively_answer_questions(state, array)
    question_name      = state.current_node
    existing_responses = state.responses

    questions_and_responses[question_name].each do |response|
      responses = existing_responses + [response]
      state     = flow.process(responses)
      next_node = flow.node(state.current_node)

      array << {
        current_node: question_name,
        responses: responses.map(&:to_s),
        next_node: next_node.name,
        outcome_node: next_node.outcome?,
      }

      unless next_node.outcome? || state.error
        recursively_answer_questions(state, array)
      end
    end

    array
  end

  def current_time
    @current_time ||= configuration.fetch(:current_time)
  end

  def configurations
    @configurations ||= YAML.load_file(Rails.root + "config/outcome_flattener.yml")
  end

  def default_configuration
    @default_configuration ||= configurations.fetch("default")
  end

  def configuration
    @configuration ||= configurations.fetch(flow_name, default_configuration)
  end

  # Disabling the linter here because this is already quite bad current_node
  # but it was copied from elsewhere and I'm not messing with it now.
  # rubocop:disable Style/MethodMissingSuper, Style/MissingRespondToMissing
  module MethodMissingHelper
    def method_missing(method, *_args, &_block)
      MethodMissingObject.new(method)
    end
  end
  # rubocop:enable Style/MethodMissingSuper, Style/MissingRespondToMissing

  class UnknownResponse < StandardError; end

  class FakeContentStore
    def content_item(*_args)
      {}
    end
  end
end
