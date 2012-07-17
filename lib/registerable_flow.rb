class RegisterableFlow
  # extend Forwardable

  def initialize(flow)
    @flow = flow
    @presenter = SmartAnswerPresenter.new(OpenStruct.new(params: {}), flow)
    @text_presenter = TextPresenter.new(flow)
  end

  def slug 
    @flow.name
  end
  
  def title
    @presenter.title
  end

  def need_id 
    @flow.need_id
  end 

  def section
    @presenter.section_name
  end

  def description
    @text_presenter.description
  end

  def indexable_content
    @text_presenter.text
  end

  def paths
    [@flow.name, "#{@flow.name}.json"]
  end

  def prefixes
    [@flow.name]
  end

  def live
    true
  end
end