require_relative '../test_helper'

require 'ostruct'

module SmartAnswer
  class GovspeakPresenterTest < ActiveSupport::TestCase
    test "parses markdown into HTML" do
      assert_equal "<h1 id=\"this-is-a-title\">This is a title</h1>\n",
                   GovspeakPresenter.new("# This is a title").html
    end
  end
end
