class RadioWithIntroQuestionPresenter < RadioQuestionPresenter
  def radio_heading
    @renderer.content_for(:radio_heading).presence
  end
end
