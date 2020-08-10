class SessionAnswersController < ApplicationController
  def show

  end

  def update

  end

  private

  def flow_name
    params[:flow_name]
  end

  def node_name
    params[:node_name]
  end

  helper_method :flow_name, :node_name
end
