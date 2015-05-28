unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name>"
  exit 1
end

path_to_outcome_directory = Rails.root.join('test', 'artefacts', flow_name)

path_to_old_outcome_files = path_to_outcome_directory.join('*.html')
path_to_new_outcome_files = path_to_outcome_directory.join('*/**/*.html')

number_of_old_outcome_files = Dir[path_to_old_outcome_files].length
number_of_new_outcome_files = Dir[path_to_new_outcome_files].length

unless number_of_new_outcome_files == number_of_old_outcome_files
  puts "Number of outcomes differ!"
  puts "New outcomes: #{number_of_new_outcome_files}"
  puts "Old outcomes: #{number_of_old_outcome_files}"
end

# I have to iterate over new outcome files as I can go from the new format
# to the old, but not vice versa. I can't know that a hyphen is definitely a
# response separator, as the response itself might contain a hyphen!
Dir[path_to_new_outcome_files].each do |outcome_file|
  print '.'

  new_outcome_filename = outcome_file.relative_path_from(path_to_outcome_directory)
  old_outcome_filename = new_outcome_filename.gsub('/', '-')

  path_to_old_outcome = path_to_outcome_directory.join(old_outcome_filename)
  path_to_new_outcome = path_to_outcome_directory.join(new_outcome_filename)

  diff = `diff #{path_to_old_outcome} #{path_to_new_outcome}`
  if diff.present?
    puts "Outcomes differ!"
    puts "Expected #{new_outcome_filename} to match #{old_outcome_filename}."
    puts diff
  end
end

puts ''
