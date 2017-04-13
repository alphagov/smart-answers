module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join('REVISION')).to_date rescue Date.today
  end

  def ajax_enabled_for?(name)
    %w(
      energy-grants-calculator
      calculate-employee-redundancy-pay
      register-a-death
    ).exclude?(name)
  end

  def start_button
    case @name.to_s
    when "overseas-passports"
      "Continue"
    when "calculate-your-child-maintenance"
      "Calculate your child maintenance"
    else
      "Start now"
    end
  end

  def start_button_href
    if @name.to_s == "overseas-passports"
      "https://www.passport.service.gov.uk/filter"
    else
      smart_answer_path(@name, started: 'y')
    end
  end
end
