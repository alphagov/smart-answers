module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join('REVISION')).to_date rescue Date.today
  end

  def start_button
    SmartAnswer::StartButton.new(@name, self).text
  end

  def start_button_href
    smart_answer_path(@name.to_s, started: "y")
  end
end
