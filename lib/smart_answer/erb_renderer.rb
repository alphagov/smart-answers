module SmartAnswer
  class ErbRenderer
    def initialize(template_directory:, template_name:, locals: {}, helpers: [])
      @template_directory, @template_name, @locals = template_directory, template_name, locals
      @view = ActionView::Base.new([@template_directory])
      helpers.each { |helper| @view.extend(helper) }
    end

    def content_for(key, html: true, govspeak: true)
      if erb_template_exists_for?(key)
        content = rendered_view.content_for(key) || ''
        content = strip_leading_spaces(content.to_str)
        (html && govspeak) ? GovspeakPresenter.new(content).html : content
      end
    end

    def erb_template_path
      @template_directory.join(erb_template_name)
    end

    private

    def erb_template_exists_for?(key)
      File.exists?(erb_template_path) && has_content_for?(key)
    end

    def erb_template_name
      "#{@template_name}.govspeak.erb"
    end

    def rendered_view
      @rendered_view ||= @view.tap do |view|
        view.render(template: erb_template_name, locals: @locals)
      end
    end

    def has_content_for?(key)
      File.read(erb_template_path) =~ /content_for #{key.inspect}/
    end

    def strip_leading_spaces(string)
      string.gsub(/^ +/, '')
    end
  end
end
