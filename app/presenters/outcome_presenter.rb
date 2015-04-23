require 'erubis'

class OutcomePresenter < NodePresenter
  include ActionView::Helpers::NumberHelper

  def title
    translate!('title')
  end

  def translate!(subkey)
    output = super(subkey)
    if output
      output.gsub!(/\+\[data_partial:(\w+):(\w+)\]/) do |match|
        render_data_partial($1, $2)
      end
    end

    output
  end

  def calendar
    @node.evaluate_calendar(@state)
  end

  def has_calendar?
    calendar.present?
  end

  def has_body?
    use_template? || super()
  end

  def body
    if use_template?
      erb_template_path = Rails.root.join("lib/smart_answer_flows/#{@node.flow_name}/#{name}.txt.erb")
      template = File.read(erb_template_path)
      govspeak = ERB.new(template).result(binding)
      GovspeakPresenter.new(govspeak).html
    else
      super()
    end
  end

  private

  attr_reader :state

  def use_template?
    @node.use_template?
  end

  def render_data_partial(partial, variable_name)
    data = @state.send(variable_name.to_sym)

    partial_path = ::SmartAnswer::FlowRegistry.instance.load_path.join("data_partials", "_#{partial}")
    ApplicationController.new.render_to_string(file: partial_path.to_s, layout: false, locals: {variable_name.to_sym => data})
  end
end
