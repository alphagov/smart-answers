# Detects and extracts content blocks from Smart Answer flows and their associated files.
#
# This class analyzes a flow's Ruby source files, calculator files, and ERB templates
# to find embedded content block references and returns the corresponding ContentBlock objects.
class ContentBlockDetector
  # Regular expression pattern to match calculator class names in the format
  # SmartAnswer::Calculators::CalculatorName
  CALCULATOR_PATTERN = /SmartAnswer::Calculators::[a-zA-Z]+/.freeze

  attr_reader :flow

  # Initializes a new ContentBlockDetector
  #
  # @param flow [Object] The Smart Answer flow object to analyze for content blocks
  def initialize(flow)
    @flow = flow
  end

  # Finds and returns all unique content blocks referenced in the flow
  #
  # Searches through all flow-related files (flow class, calculators, and templates)
  # to find content block references, extracts their embed codes, and converts them
  # to ContentBlock objects.
  #
  # @return [Array<ContentBlockTools::ContentBlock>] Array of unique content blocks found
  def content_blocks
    references = ContentBlockTools::ContentBlockReference.find_all_in_document(flow_content)
    embed_codes = references.map(&:embed_code).uniq
    embed_codes.map { |embed_code|
      ContentBlockTools::ContentBlock.from_embed_code(embed_code)
    }
  end

  # Returns the file path of the flow's main Ruby class file
  #
  # Uses memoization to cache the result after first lookup
  #
  # @return [String] File path to the flow's Ruby class definition
  def flow_filename
    @flow_filename ||= Object.const_source_location(flow.class.to_s)[0]
  end

  # Extracts and returns all calculator classes referenced in the flow file
  #
  # Scans the flow's source file for calculator class names matching the
  # CALCULATOR_PATTERN and constantizes them into actual class objects.
  # Uses memoization to cache the result.
  #
  # @return [Array<Class>] Array of calculator class objects
  def calculators
    @calculators ||= File.read(flow_filename)
                         .scan(CALCULATOR_PATTERN)
                         .map { |calculator| calculator.constantize }
  end

  # Returns file paths for all calculator classes used by the flow
  #
  # @return [Array<String>] Array of file paths to calculator class files
  def calculator_filenames
    calculators.map do |calculator|
      Object.const_source_location(calculator.to_s)[0]
    end
  end

  # Returns all ERB template file paths associated with the flow
  #
  # Searches for all .erb files in the flow's template directory,
  # which follows the naming convention: app/flows/[flow_name]_flow/**/*.erb
  #
  # @return [Array<String>] Array of ERB template file paths
  def template_filenames
    Dir.glob(File.join("app", "flows", flow.name.underscore + "_flow", "**", "*.erb"))
  end

  # Reads and concatenates the content of all flow-related files
  #
  # @return [String] Combined content of all flow files
  def flow_content
    files.map { |file|
      File.read(file)
    }.join
  end

  private

  # Returns an array of all file paths associated with the flow
  #
  # Includes the main flow file, calculator files, and all ERB templates
  #
  # @return [Array<String>] Array of file paths
  def files
    [
      flow_filename,
      *calculator_filenames,
      *template_filenames,
    ]
  end
end
