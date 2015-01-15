# encoding: UTF-8`

require 'nokogiri'

module SmartdownAdapter
  module Utils
    class SmartdownSmartAnswerCompareHelper

      def initialize(smartdown_flow_name, smartanswer_flow_name)
        @smartanswer_flow_name = smartanswer_flow_name
        @question_name = smartdown_flow_name
        @session = ActionDispatch::Integration::Session.new(Rails.application)
      end

      def diff(started=false, responses=[])
        smartanswer_content = get_smartanswer_content(started, responses)
        smartdown_content = get_smartdown_content(started, responses)
        if smartanswer_content != smartdown_content
          Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
        else
          nil
        end
      end

    private

      def get_smartanswer_content(started=false, responses=[])
        get_content(@smartanswer_flow_name, false, started, responses)
      end

      def get_smartdown_content(started=false, responses=[])
        get_content(@question_name, true, started, responses)
      end

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
end
