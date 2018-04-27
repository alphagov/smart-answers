class MarriageAbroadOutcomeFlattener
  COUNTRIES_DIR = "lib/smart_answer_flows/marriage-abroad/outcomes/countries".freeze

  FEE_TABLE_PARTIAL = <<~FEE_TABLE.freeze
    <%= render partial: 'consular_fees_table_items.govspeak.erb',
        collection: calculator.services,
        as: :service,
        locals: { calculator: calculator } %>
  FEE_TABLE

  HOW_TO_PAY_PARTIAL = <<~HOW_TO_PAY.freeze
    <%= render partial: 'how_to_pay.govspeak.erb', locals: {calculator: calculator} %>
  HOW_TO_PAY

  TITLE_PARTIAL_CONTENT = <<~TITLE.freeze
    <% if calculator.partner_is_same_sex? %>
      Civil partnership in COUNTRY
    <% else %>
      Marriage in COUNTRY
    <% end %>
  TITLE

  PAYMENT_RE = /^\^?You can( only)? pay by.*?\n.*?^$/mi
  SERVICE_FEE_RE = /^Service \| Fee\n.*?^$/mi

  attr_reader :country, :logger

  def initialize(country, logger = Logger.new(STDOUT))
    @country = country
    @logger = logger
  end

  def flatten
    logger.info "Flattening outcomes for #{country}"
    remove_old_country_partials
    copy_test_artefacts
    rename_and_add_partials_to_country_files
    create_title_partial
  end

private

  def rename_and_add_partials_to_country_files
    Dir["#{country_partials_dir}/**/{opposite_sex,same_sex}.txt"].each do |src_filename|
      dest_filename = country_outcome_filename(src_filename)
      FileUtils.mv(src_filename, dest_filename)
      insert_payment_partials(dest_filename)
    end
  end

  # Strips the first two lines of the file (the title).
  # Replaces payment instructions with a shared partial erb snippet.
  # Replaces service fee with a fees table shared partial erb snippet.
  def insert_payment_partials(filename)
    lines = IO.readlines(filename)
    text = lines[2..-1].join
    text = text.gsub(PAYMENT_RE, HOW_TO_PAY_PARTIAL)
    text = text.gsub(SERVICE_FEE_RE, FEE_TABLE_PARTIAL)

    File.write(filename, text)
    logger.info "Created outcome '#{filename}'"
  end

  def country_outcome_filename(src_filename)
    dest_filename = src_filename.gsub("txt", "erb")
    dest_filename = dest_filename.gsub("same_sex", "_same_sex")
    dest_filename.gsub("opposite_sex", "_opposite_sex")
  end

  def remove_old_country_partials
    FileUtils.rm_rf(country_partials_dir)
  end

  def copy_test_artefacts
    FileUtils.cp_r(test_artefacts_dir, country_partials_dir)
  end

  def create_title_partial
    contents = TITLE_PARTIAL_CONTENT.gsub("COUNTRY", country.titleize)
    File.open("#{country_partials_dir}/_title.govspeak.erb", "w") { |f| f.write(contents) }
  end

  def country_partials_dir
    "#{COUNTRIES_DIR}/#{country}"
  end

  def test_artefacts_dir
    "test/artefacts/marriage-abroad/#{country}"
  end
end
