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
end
