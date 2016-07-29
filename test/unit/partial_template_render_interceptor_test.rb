require_relative '../test_helper'

class PartialTemplateRenderInterceptorTest < ActiveSupport::TestCase
  setup do
    fake_renderer_class = Class.new do
      attr_accessor :template_to_set
      attr_accessor :path_to_set
      attr_accessor :args
      attr_accessor :render_return_value

      def render(*args)
        @args = args
        @template = template_to_set
        @path = path_to_set
        render_return_value
      end
    end

    @handler = mock('handler')
    interceptor = PartialTemplateRenderInterceptor[@handler]
    fake_renderer_class.prepend(interceptor)

    @renderer = fake_renderer_class.new
    @renderer.template_to_set = stub('template', identifier: 'identifier')
    @renderer.render_return_value = 'render-return-value'
  end

  should 'call renderer render method with same arguments' do
    @handler.stubs(:call)
    @renderer.render(:argument_one, :argument_two)
    assert_equal %i[argument_one argument_two], @renderer.args
  end

  should 'call handler with identifier obtained from @template' do
    @handler.expects(:call).with('identifier', anything)
    @renderer.render
  end

  should 'call handler with return value from renderer render method' do
    @handler.expects(:call).with(anything, 'render-return-value')
    @renderer.render
  end

  context '@template is not set' do
    setup do
      @renderer.template_to_set = nil
      @renderer.path_to_set = 'path-from-renderer'
    end

    should 'call handler with identifier obtained from @path' do
      @handler.expects(:call).with('path-from-renderer', anything)
      @renderer.render
    end
  end
end
