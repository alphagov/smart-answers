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

    # These methods don't share the name the presenter callees expect, alias
    def_delegator :@smartdown_state, :responses, :accepted_responses

    # The current node in the flow
    def_delegators :current_node, :body, :has_body?, :devolved_body, :has_devolved_body?

    def initialize(smartdown_flow, request)
      @smartdown_flow = smartdown_flow
      @started = request[:started]
      @processed_responses = process_inputs(responses_from_request(request))
      @smartdown_state = @smartdown_flow.state(started, @processed_responses)
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

    def current_state
      # current state is only used for responses and error, which are both
      # available on state and could be called directly, requires controller change
      OpenStruct.new(
        :responses => smartdown_state.responses
        # This is missing :error
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

    #TODO: implement once we have error handling
    # Should be moved on to question nodes, only they have errors
    def error
      nil
    end

    private

    def responses_from_request(request)
      responses = []
      if request[:params]
        responses += request[:params].split("/")
      end

      # url request
      if request[:responses]
        split_responses = request[:responses].split("/")
        responses += split_responses
      end

      # get form submission request: one response
      if request[:response]
        responses << request[:response]
      end

      #get form submission request: for multiple responses
      response_array = request.query_parameters.select { |key| key.to_s.match(/^response_\d+/) }
                                                .map { |response_key| response_key[1] }
      responses += response_array unless response_array.empty?
      responses
    end

    def process_inputs(responses)
      responses.map do |response|
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

    def presenter_for_current_node
      smartdown_node = smartdown_state.current_node
      case smartdown_node
        when Smartdown::Api::QuestionPage
          SmartdownAdapter::QuestionPagePresenter.new(smartdown_node)
        else
          SmartdownAdapter::NodePresenter.new(smartdown_node)
      end

    end

    def presenters_for_previous_nodes
      smartdown_state.previous_question_pages(@processed_responses).map do |smartdown_previous_question_page|
        SmartdownAdapter::PreviousQuestionPagePresenter.new(smartdown_previous_question_page)
      end
    end

  end
end
