require 'erubis'

class OutcomePresenter < NodePresenter
  include OutcomeHelper

  def title
    translate!('title')
  end

  def translate!(subkey)
    output = super(subkey)
    output.gsub!(/\+\[contact_list\]/,contact_list) unless output.nil?

    output
  end

  def contact_list
    @contact_list = @node.contact_list_sym ? @state.send(@node.contact_list_sym) : []
    Erubis::Eruby.new( File.read Rails.root.join('app','views','smart_answers','_contact_list.html.erb') ).result(binding)
  end

  def has_calendar?
    ! @node.calendar_object.nil?
  end

  def calendar
    @node.calendar_object
  end
end
