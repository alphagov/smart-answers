require 'ostruct'

class UkbaCountry < OpenStruct
  def self.all
    @countries ||= YAML.load_file(Rails.root.join('lib', 'data', 'ukba_additional_countries.yml')).map { |c| self.new(c) }
  end
end
