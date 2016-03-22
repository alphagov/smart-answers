require 'ostruct'

class LegacyCountry < OpenStruct
  def self.all
    @countries ||= YAML.load_file(Rails.root.join('lib', 'data', 'countries.yml')).map { |c| self.new(c) }
  end
end
