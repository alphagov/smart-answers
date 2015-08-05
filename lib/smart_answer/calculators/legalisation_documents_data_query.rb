module SmartAnswer::Calculators
  class LegalisationDocumentsDataQuery
    attr_reader :legalisation_document_data, :data

    def initialize
      @data = self.class.legalisation_document_data
      @legalisation_document_data = self.class.legalisation_document_data
    end

    def find_document_data(documents)
      legalisation_document_data[documents]
    end

    def self.legalisation_document_data
      @legalisation_document_data ||= YAML.load_file(Rails.root.join("lib", "data", "legalisation_documents_data.yml"))
    end
  end
end
