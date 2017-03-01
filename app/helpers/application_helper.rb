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
end
