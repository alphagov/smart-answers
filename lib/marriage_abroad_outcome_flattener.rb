class MarriageAbroadOutcomeFlattener
  COUNTRIES_DIR = "lib/smart_answer_flows/marriage-abroad/outcomes/countries".freeze

  def initialize(country, same_sex_wording:, logger: Logger.new(STDOUT))
    @country = country

    @same_sex_wording = case same_sex_wording
                        when :civil_partnership
                          "Civil partnership"
                        when :same_sex_marriage
                          "Same-sex marriage"
                        when :both
                          "Same-sex marriage and civil partnership"
                        end

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

  attr_reader :country, :logger, :same_sex_wording

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

    text = replace_how_to_pay(text)
    text = replace_fee_table(text)

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
    File.open("#{country_partials_dir}/_title.govspeak.erb", "w") { |f| f.write(title_contents) }
  end

  def country_partials_dir
    "#{COUNTRIES_DIR}/#{country}"
  end

  def test_artefacts_dir
    "test/artefacts/marriage-abroad/#{country}"
  end

  def replace_how_to_pay(text)
    text.gsub(
      /^\^?You can( only)? pay by.*?\n.*?^$/mi,
      <<~HOW_TO_PAY.freeze
        <%= render partial: 'how_to_pay.govspeak.erb', locals: {calculator: calculator} %>
      HOW_TO_PAY
    )
  end

  def replace_fee_table(text)
    text.gsub(
      /^Service \| Fee\n.*?^$/mi,
      <<~FEE_TABLE.freeze
        <%= render partial: 'consular_fees_table_items.govspeak.erb',
            collection: calculator.services,
            as: :service,
            locals: { calculator: calculator } %>
      FEE_TABLE
    )
  end

  def title_contents
    <<~TITLE.freeze
      <% if calculator.partner_is_same_sex? %>
        #{same_sex_wording} in #{country.titleize}
      <% else %>
        Marriage in #{country.titleize}
      <% end %>
    TITLE
  end
end
