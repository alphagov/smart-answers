country = ARGV.shift
sex_of_partner = ARGV.shift
residency = ARGV.shift
partner_nationality = ARGV.shift
services = ARGV

def display_usage_message_and_exit
  puts "Usage: #{__FILE__} <country> <sex_of_partner> <residency> <partner_nationality> <services>"
  exit 1
end

unless country
  display_usage_message_and_exit
end

unless %(same_sex opposite_sex).include?(sex_of_partner)
  puts "Invalid sex_of_partner: #{sex_of_partner}"
  display_usage_message_and_exit
end

unless %w(ceremony_country third_country uk default).include?(residency)
  puts "Invalid residency: #{residency}"
  display_usage_message_and_exit
end

unless %w(partner_british partner_local partner_other default).include?(partner_nationality)
  puts "Invalid partner_nationality: #{partner_nationality}"
  display_usage_message_and_exit
end

unless services.any?
  display_usage_message_and_exit
end

marriage_abroad_services_file = Rails.root.join('lib', 'data', 'marriage_abroad_services.yml')
yaml = File.read(marriage_abroad_services_file)
data = YAML.load(yaml)

data[country] ||= {}
data[country][sex_of_partner] ||= {}
data[country][sex_of_partner][residency] ||= {}
data[country][sex_of_partner][residency][partner_nationality] = services.map(&:to_sym)

File.open(marriage_abroad_services_file, 'w') do |file|
  file.puts(data.to_yaml)
end
