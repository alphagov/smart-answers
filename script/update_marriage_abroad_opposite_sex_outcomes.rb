require "csv"
require "find"

# Variations
# 1 - commission text with link
# 2 - embassy text with link
# 3 - government text
# 4 - commission text with link (above ##Prove you're free to get married)
# 5 - embassy text with link (above ##Prove you're free to get married)
# 6 - embassy text with link (above ##What you need)
# 7 - consulate text with link (above ##What you need to do)
# 8 - embassy text with link (above ##After you get married)

COUNTRIES_DIR = "lib/smart_answer_flows/marriage-abroad/outcomes/countries/".freeze
OPPOSITE_SEX_FILE = "_opposite_sex".freeze
UPDATE_OUTCOMES_CSV = "script/update_outcomes.csv".freeze

def get_country_folder(country)
  if country.include?("of the")
    country.gsub(" ", "-").downcase
  else
    country.gsub("the ", "").gsub(" ", "-").downcase
  end
end

def text_variation(variation, link)
  case variation
  when 1, 4 # commission text with link, eof
    "You might be able to form an opposite sex civil partnership. Check the local rules with the [British high commission](#{link})."
  when 2, 5, 6, 8 # embassy text with link
    "You might be able to form an opposite sex civil partnership. Check the local rules with the [British embassy](#{link})."
  when 3 # government text
    "You might be able to form an opposite sex civil partnership. Check the rules with the local government."
  when 7 # consulate text with link
    "You might be able to form an opposite sex civil partnership. Check the local rules with the [British consulate](#{link})."
  end
end

def append_to_eof(opposite_sex_paths, text)
  text = "\n" + text + "\n"
  puts "The following text will be added to the end of files:"
  puts text

  opposite_sex_paths.each do |path|
    File.write(path, text, mode: "a")
    puts "File has been updated: #{path}"
  end
end

def insert_above_heading(opposite_sex_paths, variation, text)
  if variation.between?(4, 5)
    heading_match = "Prove you’re free to get married"
  elsif variation.between?(6, 7)
    heading_match = "What you need to do"
  elsif variation == 8
    heading_match = "After you get married"
  end

  text += "\n\n"
  puts "The following text will be inserted above the heading ## #{heading_match}:"
  puts text

  text += "## #{heading_match}"

  opposite_sex_paths.each do |path|
    file = File.read(path)

    if file.include?(heading_match)
      regex = /## ?#{heading_match}/
      if file =~ regex
        file.gsub!(file.match(regex)[0], text)
      else
        puts "Match is not a H2 heading"
      end
      File.write(path, file)
      puts "File has been updated: #{path}"
    else
      puts "Heading match not found in file: #{path}"
    end
  end
end

country_outcomes_csv = CSV.read(UPDATE_OUTCOMES_CSV, headers: true)
csv_headings = country_outcomes_csv.headers

updated_count = 0

CSV.open(UPDATE_OUTCOMES_CSV, "wb", write_headers: true, headers: csv_headings) do |csv_write|
  country_outcomes_csv.each do |row|
    country = row[0]
    variation = row[1].to_i
    link = row[2]
    updated = row[3]

    if updated_count.zero? && updated.blank? || updated == "false"
      text = text_variation(variation, link)
      country_folder = get_country_folder(country)
      country_dir = File.open(COUNTRIES_DIR + country_folder)
      opposite_sex_paths = []

      puts "=== Changes to #{country} opposite sex outcomes, using variation #{variation} ==="

      Find.find(country_dir) do |path| # find outcomes for country
        opposite_sex_paths << path if path =~ /_opposite_sex.*.erb/
      end

      if opposite_sex_paths.length.positive?
        puts "Found #{opposite_sex_paths.length} files called '#{OPPOSITE_SEX_FILE}' in the directory #{COUNTRIES_DIR + country_folder}:"
        puts opposite_sex_paths.to_s
      else
        puts "No files called #{OPPOSITE_SEX_FILE} found in the directory"
      end

      if variation.between?(1, 3)
        append_to_eof(opposite_sex_paths, text)
        updated = "true"
        updated_count += 1
      elsif variation.between?(4, 8)
        insert_above_heading(opposite_sex_paths, variation, text)
        updated = "true"
        updated_count += 1
      else
        puts "Variation is out of range"
      end
    end

    csv_write << [country, variation, link, updated]
  end
end

if updated_count.zero?
  puts "No updates applied."
end
