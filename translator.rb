require 'rubygems'
require 'csv'
#require 'ap'
require 'httparty'

def import_csv(file)
  CSV.foreach(file, :headers => true) do |row|
    yield row
  end
end

def export_csv(file, data)
  CSV.open(file, 'wb') do |csv|
    data.each do |row|
      csv << row
    end
  end
end


class Translator
  include HTTParty
  default_params :source => "en", :target => "ar", :key => "AIzaSyBZqoFfZUVLlMs7--YWOEJR_ylC8gCNtDM"
  format :json


  def self.t(keyword)
    result = get("https://www.googleapis.com/language/translate/v2", :query => {:q => keyword})
    result["data"]["translations"][0]["translatedText"]
  end
end


##############################
# work starts from here
# run:
#
# $ ruby translator.rb INPUT_FILE [OUTPUT_FILE]
##############################

# get csv file
file_in = ARGV.shift
if file_in.nil?
  puts "#{$0}: INPUT_FILE [OUTPUT_FILE]"
  exit 1
end

file_out = ARGV.shift || "data_out.csv"
data = []  # data to write

import_csv(file_in) do |row|
#  row["value"] = Translator.t(row["value"]).gsub /(.*)/, '"\0'
  puts row["value"]
  row["value"] = Translator.t(row["value"])

  data << row
end

export_csv(file_out, data)
