module DomTestingAssertions
  include Rails::Dom::Testing::Assertions

  def css_select_for(html, *args)
    node = Nokogiri::HTML::DocumentFragment.parse(html)
    css_select node, *args
  end

  def assert_select_for(html, *args)
    node = Nokogiri::HTML::DocumentFragment.parse(html)
    assert_select node, *args
  end
end
