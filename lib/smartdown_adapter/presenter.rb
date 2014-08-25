require 'gds_api/helpers'

module SmartdownAdapter

  class Presenter
    include GdsApi::Helpers
    extend Forwardable
    include Rails.application.routes.url_helpers

    attr_accessor :name, :started, :smartdown_flow, :smartdown_state

    # The same for all nodes/views
    def_delegators :@smartdown_flow, :title, :meta_description, :need_id

    # Where you are in the flow
    def_delegators :@smartdown_state, :current_question_number, :started?, :finished?

    # These methods don't share the name the presenter callees expect, alias
    def_delegator :@smartdown_state, :responses, :accepted_responses

    # The current node in the flow
    def_delegators :current_node, :body, :has_body?, :devolved_body, :has_devolved_body?

    def initialize(name, request)
      @name = name
      @started = request[:started]
      @responses = responses_from_request(request)
      @smartdown_flow = SmartdownAdapter::Registry.build_flow(name)
      @smartdown_state = @smartdown_flow.state(started, @responses)
    end

    def questions
      current_node.questions
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
    def change_collapsed_question_link(question_number)
      smart_answer_path(
          id: name,
          started: 'y',
          responses: accepted_responses[0...question_number - 1],
          previous_response: accepted_responses[question_number - 1]
      )
    end

    #TODO: implement once we have error handling
    # Should be moved on to question nodes, only they have errors
    def error
      nil
    end

    private

    #TODO: extract this somewhere else, a lot in common with smart answer presenter
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

    def presenter_for_current_node
      smartdown_node = smartdown_state.current_node
      case smartdown_node
        when Smartdown::Api::QuestionPage
          QuestionPagePresenter.new(smartdown_flow, smartdown_state.previous_question_pages(@responses), smartdown_node)
        else
          NodePresenter.new(smartdown_node)
      end

    end

    def presenters_for_previous_nodes
      previous_question_pages = smartdown_state.previous_question_pages(@responses)
      result = []
      for i in (1..previous_question_pages.count)
        result << PreviousQuestionPagePresenter.new(smartdown_flow, previous_question_pages[0...i])
      end
      result
    end

  end
end
