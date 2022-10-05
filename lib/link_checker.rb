class LinkChecker
  attr_reader :texts

  def initialize(texts)
    @texts = texts
  end

  def urls
    @urls ||= extract_urls
  end

  def report
    return if urls.blank?

    @report ||= generate_report
  end

private

  def extract_urls
    return Set[] if texts.blank?

    urls = texts.map { |text| URI.extract(text, %w[http https]) }
    urls.flatten!
    urls.map! { |uri| remove_unmatched_closing_bracket_from_end(uri) }
    urls.to_set
  end

  def remove_unmatched_closing_bracket_from_end(text)
    text.gsub!(/\)[^)\w]?$/, "") if unmatched_closing_bracket?(text)
    text
  end

  def unmatched_closing_bracket?(text)
    text.count("(") < text.count(")")
  end

  def generate_report
    link_report = link_checker_api.create_batch(urls, checked_within: 5)
    wait_time = 1

    while link_report.status == :in_progress
      sleep(wait_time)
      link_report = link_checker_api.get_batch(link_report.id)
      wait_time *= 1.5
    end
    link_report
  end

  def link_checker_api
    @link_checker_api ||= GdsApi::LinkCheckerApi.new(
      Plek.new.find("link-checker-api"),
      bearer_token: ENV["LINK_CHECKER_API_BEARER_TOKEN"],
    )
  end
end
