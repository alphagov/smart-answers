namespace :smartdown do

  def smartdown_coversheet_path(flow_name, coversheet_name= flow_name)
    File.join(smartdown_flow_path(flow_name), "#{coversheet_name}.txt")
  end

  def smartdown_flow_path(flow_name)
    Rails.root.join('lib', 'smartdown_flows', flow_name)
  end

  desc "Rename a Smartdown directory package, including coversheet"
  task :rename, [:old_name, :new_name] do |t, args|
    old_name = args[:old_name]
    new_name = args[:new_name]
    `git mv #{smartdown_flow_path(old_name)} #{smartdown_flow_path(new_name)}`
    `git mv #{smartdown_coversheet_path(new_name, old_name)} #{smartdown_coversheet_path(new_name)}`
  end
end
