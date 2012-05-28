module SmartAnswer
  module Question
    class CountrySelect < MultipleChoice
      def initialize(name, options = {}, &block)
        options = country_list
        super(name, options, &block)
      end

      def options
        country_list
      end

      def country_list
        @countries ||= YAML::load( File.open( Rails.root.join('lib', 'smart_answer', 'templates', 'countries.yml') ))
      end

      def valid_option?(option)
        options.map{|v| v[:slug]}.include? (option.to_s)
      end

      def to_response(input)
        country_list[input]
      end
    end
  end
end