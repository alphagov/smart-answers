require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class LinkCheckerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  def url
    @url ||= "http://example.com"
  end

  def text
    @text ||= %(There is a link <a href="#{url}">here</a>)
  end

  def link_checker
    @link_checker ||= LinkChecker.new([text])
  end

  context "#urls" do
    should "return set of urls in text" do
      assert_equal Set[url], link_checker.urls
    end

    context "when text contains no links" do
      should "return an empty set" do
        @text = "No links"
        assert_equal Set[], link_checker.urls
      end
    end

    context "when text contains link markup" do
      should "return set of urls in text" do
        @text = "There is a link [here](#{url})"
        assert_equal Set[url], link_checker.urls
      end
    end

    context "when text contains link markup and url end with a bracket" do
      should "return set of urls in text" do
        @url = "http://example.com/this(thing)"
        @text = "There is a link [here](#{url})"
        assert_equal Set[url], link_checker.urls
      end
    end

    context "when stings missing" do
      should "return an empty set" do
        @link_checker = LinkChecker.new(nil)
        assert_equal Set[], link_checker.urls
      end
    end
  end

  context "#report" do
    should "generate a report" do
      stub_link_checker_api_create_batch(
        uris: [url], checked_within: 5, status: :completed,
      )
      assert_equal url, link_checker.report.links.first.uri
    end
  end
end
