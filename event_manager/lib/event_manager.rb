# The Sunlight gem will need to be installed.
# % gem install sunlight-congress

require 'csv'
require 'erb'
require 'fileutils'
require 'sunlight/congress'

STDERR.puts "event_attendees.csv does not exist" unless File.exist?("event_attendees.csv")
STDERR.puts "form_letter.erb does not exist" unless File.exist?("form_letter.erb")
ERB_TEMPLATE = ERB.new(File.read("form_letter.erb"))
Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone)
  # Strip out all non-digits first.
  sanitized_number = phone.gsub(/[^\d]/, "") unless phone.nil?

  if sanitized_number.length < 10 || sanitized_number.length > 11
    ""
  elsif sanitized_number.length == 10
    sanitized_number
  elsif sanitized_number.length == 11
    return sanitized_number[1..-1] if sanitized_number[0] == "1"
    ""
  end
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thanks(id, letter)
  File.write("letters/thanks_#{id}.html", letter)
end


FileUtils.mkdir("letters") unless Dir.exist?("letters")
hour_registered = []
hour_counts = {}

CSV.foreach("event_attendees.csv", headers: :first_row, header_converters: :symbol) do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_number(row[:homephone])
  reg_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
  hour_registered << reg_date.hour
  legislators = legislators_by_zipcode(zipcode)

  letter = ERB_TEMPLATE.result(binding)
  save_thanks(id, letter)
  print "."
end

print "\n"
hour_registered.uniq.each do |hour|
  hour_counts[hour] = hour_registered.count(hour)
end
puts "Most popular hour of the day for registration: #{hour_counts.key(hour_counts.values.sort[-1])}"
