module RecruitmentBannerHelper
  def recruitment_banner
    return false if recruitment_banners.nil?

    current_path = request.path

    recruitment_banners.find do |banner|
      next unless valid?(banner)

      banner["page_paths"]&.include?(current_path)
    end
  end

  def recruitment_banners
    recruitment_banners_urls_file_path = Rails.root.join("lib/data/recruitment_banners.yml")
    recruitment_banners_data = YAML.load_file(recruitment_banners_urls_file_path)
    recruitment_banners_data["banners"]
  end

  def valid?(banner)
    required_fields.select { |field| banner[field].present? } == required_fields
  end

  def required_fields
    %w[survey_url suggestion_text suggestion_link_text page_paths]
  end
end
