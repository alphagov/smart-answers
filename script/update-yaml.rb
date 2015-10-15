Dir[Rails.root.join('test', 'data', '*.yml')].each do |filename|
  data = YAML.load_file(filename)
  File.open(filename, 'w') do |file|
    file.write(YAML.dump(data))
  end
end
