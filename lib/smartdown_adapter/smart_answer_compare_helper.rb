require 'nokogiri'

module SmartdownAdapter
  class SmartAnswerCompareHelper

    def initialize(smartdown_flow, exceptions = {}, smartanswer_question_flow_name = nil)
      @smartdown_flow = smartdown_flow
      #Exceptions are a hack put in place to be able to replace strings
      #rendered in Smartdown with their equivalents in smart-answers
      #This is mainly made to avoid very verbose diffs for
      #minor white space differences
      @exceptions = exceptions
      @question_name = smartdown_flow.name
      if smartanswer_question_flow_name
        @smartanswer_question_name = smartanswer_question_flow_name
      else
        @smartanswer_question_name = @question_name.chomp('-transition')
      end
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def get_smartanswer_content(started=false, responses=[])
      get_content(@smartanswer_question_name, false, started, responses)
    end

    def get_smartdown_content(started=false, responses=[])
      get_content(@question_name, true, started, responses)
    end

    def scenario_answer_sequences
      answer_groups = []
      @smartdown_flow.scenario_sets.each do |scenario_set|
        scenario_set.scenarios.each_with_index do |scenario, scenario_index|
          scenario.question_groups.each_with_index do |question_group, question_index|
            answer_groups << scenario.question_groups[0..question_index].flatten.map(&:answer)
          end
        end
      end
      answer_groups.uniq!
      answer_groups
    end

  private

    def get_content(question_name, is_smartdown, started, responses)
      url = "/#{question_name}"
      if started
        url += "/y"
      end
      unless responses.empty?
        url += "/"+responses.join("/")
      end
      @session.get url
      normalise_content(@session.response.body, is_smartdown)
    end

    def normalise_content(html, is_smartdown)
      # This removes sidebar/breadcrumb/analytics differences (as transition
      # has no artefact for content to be inserted for)
      # It would be preferable to stub out the artefact fetching call somehow..
      doc = Nokogiri::HTML(@session.response.body)
      doc.css(".related-positioning").remove
      doc.css("#global-breadcrumb").remove
      doc.css("#ga-params").remove
      response = doc.to_s

      # Removing by ID leaves some noise which we have to regex out
      response.gsub!("<!-- related -->\n<!-- end related -->\n\n  ", "")
      if is_smartdown
        # Remove the transition slug, which will cause diffs in lots of hrefs
        response.gsub!('-transition', '')
        exceptions.each do |smartdown_string, smartanswer_string|
          response.gsub!(smartdown_string, smartanswer_string)
        end
      end
      response
    end

    def get_file_as_string(filename)
      data = ''
      f = File.open(filename, "r")
      f.each_line do |line|
        data += line
      end
      data
    end
  end
end
