module EducationNavigationABTestable
  def should_present_new_navigation_view?(content_item)
    education_navigation_variant.variant_b? && content_is_tagged_to_a_taxon?(content_item)
  end

  def education_navigation_variant
    @education_navigation_variant ||= education_navigation_ab_test.requested_variant request.headers
  end

  def page_is_under_ab_test?(content_item)
    content_is_tagged_to_a_taxon?(content_item)
  end

  def set_education_navigation_response_header(content_item)
    if page_is_under_ab_test?(content_item)
      education_navigation_variant.configure_response response
    end
  end

  def self.included(base)
    base.helper_method :education_navigation_variant
  end

private

  def education_navigation_ab_test
    @ab_test ||= GovukAbTesting::AbTest.new("EducationNavigation", dimension: 41)
  end

  def content_is_tagged_to_a_taxon?(content_item)
    content_item.dig("links", "taxons").present?
  end
end
