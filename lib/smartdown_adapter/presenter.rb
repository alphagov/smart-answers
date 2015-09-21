require 'gds_api/helpers'

module SmartdownAdapter

  class Presenter
    include GdsApi::Helpers
    extend Forwardable
    include Rails.application.routes.url_helpers

    attr_accessor :started, :smartdown_flow, :smartdown_state

    # The same for all nodes/views
    def_delegators :@smartdown_flow, :name, :title, :meta_description, :need_id

    # Where you are in the flow
    def_delegators :@smartdown_state, :current_question_number, :started?, :finished?

    # The current node in the flow
    def_delegators :current_node, :body, :post_body

    def initialize(smartdown_flow, request)
      @smartdown_flow = smartdown_flow
      @started = request[:started]
      previous_smartdown_inputs = process_inputs(responses_from_url(request))
      @previous_smartdown_state = @smartdown_flow.state(started, previous_smartdown_inputs)
      @responses_url_and_request = process_inputs(responses_from_request(request))
      @smartdown_state = @smartdown_flow.state(started, @responses_url_and_request)
    end

    def accepted_responses
      @smartdown_state.accepted_responses
    end

    def questions
      current_node.questions
    end

    def page_title
      current_node.title
    end

    def current_node
      @current_node ||= presenter_for_current_node
    end

    def start_node
      self
    end

    def accepted_responses
      smartdown_state.accepted_responses
    end

    def current_state
      # current state is only used for responses and error, which are both
      # available on state and could be called directly, requires controller change
      OpenStruct.new(
        responses: accepted_responses,
        unaccepted_responses: @smartdown_state.current_answers.map(&:value).map(&:to_s),
      )
    end

    def collapsed_question_pages
      presenters_for_previous_nodes
    end

    #COPY/PASTE from old presenter
    def artefact
      @artefact ||= content_api.artefact(name)
    rescue GdsApi::HTTPErrorResponse
      {}
    end

    # Probably should be deprecated, just call the real method and see?
    # Requires template updates
    def has_meta_description?
      !!meta_description
    end

    def has_subtitle?
      !!subtitle
    end

    def subtitle
    end
    # -- end probably deprecated methods

    # Template helper that is aware of state, eg, name, responses
    def change_collapsed_question_link(question_number, number_questions_changed_page = 1)
      responses_up_to_changed_page = accepted_responses[0...question_number - 1]
      number_responses_to_keep = question_number + number_questions_changed_page
      responses_including_changed_page =  accepted_responses[0...number_responses_to_keep -1]
      previous_responses_hash = {}
      responses_including_changed_page
        .last(number_questions_changed_page)
        .each_with_index do |response, response_index|
          answer_number = responses_including_changed_page.last(number_questions_changed_page).size > 1 ? "_#{response_index + 1}" : ""
          previous_responses_hash["previous_response#{answer_number}"] = response
        end

      url_hash = previous_responses_hash.merge(
        id: name,
        started: 'y',
        responses:  responses_up_to_changed_page,
      )

      smart_answer_path(url_hash)
    end

    def render_txt?
      false
    end

    private

    def responses_from_request(request)
      responses_from_url(request) +
      responses_from_query_params(request)
    end

    def responses_from_url(request)
      responses = []
      if request[:params]
        responses += request[:params].split("/")
      end

      # url request
      if request[:responses]
        split_responses = request[:responses].split("/")
        responses += split_responses
      end
      responses
    end

    def responses_from_query_params(request)
      responses = []
      if request[:response]
        responses << request[:response]
      end

      if request[:next]
        (@previous_smartdown_state.current_node.questions.count - responses.count).times do |index|
          responses << request.query_parameters["response_#{index+1}"] || nil
        end
      end
      responses
    end

    def process_inputs(responses)
      responses.map do |response|
        if response == ''
          nil
        else
          if response.is_a? Hash
            if response.has_key?(:day)
              "#{response[:year]}-#{response[:month]}-#{response[:day]}"
            elsif response.has_key?(:amount)
              "#{response[:amount]}-#{response[:period]}"
            end
          else
            response
          end
        end
      end
    end

    def presenter_for_current_node
      smartdown_node = smartdown_state.current_node
      current_smartdown_answers = smartdown_state.current_answers
      case smartdown_node
        when Smartdown::Api::QuestionPage
          SmartdownAdapter::QuestionPagePresenter.new(smartdown_node, current_smartdown_answers)
        else
          SmartdownAdapter::NodePresenter.new(smartdown_node)
      end
    end

    def presenters_for_previous_nodes
      smartdown_state.previous_question_pages.map do |smartdown_previous_question_page|
        SmartdownAdapter::PreviousQuestionPagePresenter.new(smartdown_previous_question_page)
      end
    end

  end
end
