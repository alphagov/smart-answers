namespace :smartdown do

  def smartdown_coversheet_path(flow_name, coversheet_name= flow_name)
    File.join(smartdown_flow_path(flow_name), "#{coversheet_name}.txt")
  end

  def smartdown_flow_path(flow_name)
    Rails.root.join('lib', 'smartdown_flows', flow_name)
  end

  def smartdown_set_flow_status(flow_name, status)
    coversheet = smartdown_coversheet_path(flow_name)
    IO.write(coversheet, File.read(coversheet).sub(/status: .*/, "status: #{status}"))
  end

  desc "Rename a Smartdown directory package, including coversheet"
  task :rename, [:old_name, :new_name] do |t, args|
    old_name = args[:old_name]
    new_name = args[:new_name]
    `git mv #{smartdown_flow_path(old_name)} #{smartdown_flow_path(new_name)}`
    `git mv #{smartdown_coversheet_path(new_name, old_name)} #{smartdown_coversheet_path(new_name)}`
  end

  desc "Convert a Smartdown package to transition status/name"
  task :to_transition, [:name] do |t, args|
    name = args[:name]
    smartdown_set_flow_status(name, 'transition')
    Rake::Task["smartdown:rename"].invoke(name, "#{name}-transition")
  end

  desc "Convert a Smartdown package from transition status/name to published"
  task :from_transition, [:name] do |t, args|
    name = args[:name]
    smartdown_set_flow_status(name, 'published')
    Rake::Task["smartdown:rename"].invoke(name, name.chomp('-transition'))
  end
end
