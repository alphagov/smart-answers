# Time Formats
# ============
#
# Adds named date and time formats for time.to_s and date.to_s
#
# To display the current date and time in all the formats in your current environment:
#
#   Date::DATE_FORMATS.keys.push(:default).each{|k| puts "#{k}: #{Date.today.to_s(k)}"}
#   Time::DATE_FORMATS.keys.push(:default).each{|k| puts "#{k}: #{Time.now.to_s(k)}"}
#
# For examples time = Time.local(2009,12,4,15,30,27)

shared_formats = {
  govuk_date: "%-d %B %Y", # '4 December 2009'
}

Time::DATE_FORMATS.merge! shared_formats
Date::DATE_FORMATS.merge! shared_formats
