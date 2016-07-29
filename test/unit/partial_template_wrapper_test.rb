require_relative '../test_helper'

class PartialTemplateWrapperTest < ActiveSupport::TestCase
  include DomTestingAssertions

  setup do
    @wrapper = PartialTemplateWrapper.new
  end

  context 'partial template is in app/views directory' do
    setup do
      @identifier = Rails.root.join('app/views/controller_name/_partial')
    end

    should 'leave content unchanged' do
      assert_equal 'content', @wrapper.call(@identifier, 'content')
    end
  end

  context 'partial template is not in app/views directory' do
    setup do
      @identifier = Rails.root.join('lib/smart_answer_flows/flow-name/outcomes/_partial')
    end

    context 'and content is blank' do
      setup do
        @content = ' ' * 10
      end

      should 'leave content unchanged' do
        assert_equal @content, @wrapper.call(@identifier, @content)
      end
    end

    context 'and content is not blank' do
      setup do
        @content = 'content'
      end

      should 'wrap content in a div element' do
        html = @wrapper.call(@identifier, @content)
        assert_select_for html, "div:contains('#{@content}')"
      end

      should 'wrap content in newlines within div element so govspeak works' do
        html = @wrapper.call(@identifier, @content)
        div = css_select_for html, 'div'
        assert_equal "\n" + @content + "\n", div.text
      end

      should 'add markdown attribute to enable govspeak processing of content' do
        html = @wrapper.call(@identifier, @content)
        assert_select_for html, "*[markdown='1']"
      end

      should 'add debug-partial-template-path data attribute' do
        expected_path = @identifier.relative_path_from(Rails.root).to_s
        html = @wrapper.call(@identifier, @content)
        assert_select_for html, "*[data-debug-partial-template-path='#{expected_path}']"
      end
    end

    context 'and content includes an ampersand' do
      setup do
        @content = 'content & more content'
      end

      should 'not HTML-escape content' do
        html = @wrapper.call(@identifier, @content)
        assert_select_for html, "div:contains('#{@content}')"
      end
    end
  end
end
