class FlowRegistrationPresenter
  include ContentItemHelper

  def initialize(flow)
    @flow = flow
  end

  def slug
    @flow.name
  end

  def need_content_id
    @flow.need_content_id
  end

  def start_page_content_id
    @flow.start_page_content_id
  end

  def flow_content_id
    @flow.flow_content_id
  end

  delegate :title, to: :start_node

  def description
    start_node.meta_description
  end

  def external_related_links
    @flow.external_related_links || []
  end

  def start_page_body
    start_node.body
  end

  def start_page_post_body
    start_node.post_body
  end

  def start_page_button_text
    start_node.start_button_text
  end

  def publish?
    @flow.status == :published
  end

  def flows_content
    extract_flow_content(@flow)
  end

private

  def start_node
    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    StartNodePresenter.new(node)
  end
end
