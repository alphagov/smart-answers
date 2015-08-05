require 'open-uri'
require 'nokogiri'

class FCOEmbassyScraper
  INDEX_URL = "http://www.fco.gov.uk/en/travel-and-living-abroad/find-an-embassy/"

  def self.scrape
    self.new.run
  end

  def initialize
    @urls = []
    @embassies = {}
    @countries = YAML.load_file(File.expand_path('../countries.yml', __FILE__))
    @index_uri = URI.parse(INDEX_URL)
  end

  attr_reader :embassies

  def run
    process_index
    @urls.each do |url|
      begin
        e = process_embassy_page(url)
        country_name = e.delete("country")
        country = case country_name
                  when "Côte d'Ivoire"
                    {slug: "cote-d_ivoire-(ivory-coast)"}
                  when "Dominica"
                    {slug: "dominica,-commonwealth-of"}
                  when "Equatorial Guinea - BHC Yaoundé"
                    {slug: "equatorial-guinea"}
                  when "Kyrgystan"
                    {slug: "kyrgyzstan"}
                  when "Niger - British High Commission"
                    {slug: "niger"}
                  when "Pitcairn Henderson Ducie & Oeno Islands"
                    {slug: "pitcairn"}
                  else
                    @countries.find {|c| c[:name].downcase == country_name.downcase }
                  end
        if country
          @embassies[country[:slug]] ||= []
          @embassies[country[:slug]] << e
        else
          puts "Couldn't resolv slug for country #{country_name}, url: #{url}"
        end
      rescue => ex
        puts "Error #{ex.class}: #{ex.message} processing #{url}"
      end
    end
    @embassies
  end

  def process_index
    page = Nokogiri::HTML(@index_uri.open)
    page.css('#newA2ZCountryLink').each do |link|
      @urls << URI.join(@index_uri, link["href"])
    end
  end

  def process_embassy_page(uri)
    page = Nokogiri::HTML(uri.open)
    page_title = page.at_css('h1').text.strip
    country = page_title.split(',').first
    raise "Strange country name: #{country}" if country == "Access denied"
    embassy = {"country" => country}
    page.css('table.Embassy tr').each do |row|
      items = row.css('td')
      key = items.first.text.strip
      next if key.blank?
      key = key.downcase.chomp(':').gsub(/\s/, '_')

      value = items.last
      value = Nokogiri::HTML::DocumentFragment.parse(value.inner_html.gsub('<br>', "\n")).text
      value = value.gsub("\u00A0", ' ').gsub("\u2013", '-').strip
      embassy[key] = value
    end
    embassy
  end
end
