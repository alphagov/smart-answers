module EducationNavigationABTestable
  def should_present_new_navigation_view?
    (education_navigation_ab_testing_group == "B") && new_navigation_enabled? && content_is_tagged_to_a_taxon?
  end

  def education_navigation_ab_testing_group
    request.headers["HTTP_GOVUK_ABTEST_EDUCATIONNAVIGATION"] == "B" ? "B" : "A"
  end

  def new_navigation_enabled?
    ENV['ENABLE_NEW_NAVIGATION'] == 'yes'
  end

  def content_is_tagged_to_a_taxon?
    !@content_item.dig("links", "taxons").blank?
  end
end
