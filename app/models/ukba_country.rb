require "ostruct"

class UkbaCountry < OpenStruct
  def self.all
    @all ||= YAML.load_file(Rails.root.join("config/smart_answers/ukba_additional_countries.yml")).map { |c| new(c) }
  end
end
