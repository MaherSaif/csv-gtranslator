require 'rubygems'
require 'csv'
require 'httparty'
#require 'ap'

class MyCSV
  attr_accessor :data

  def initialize(in_file, out_file = nil, options = {})
    @in_file = in_file
    @out_file = out_file || "data_out.csv"
    @options = {:headers => true}.merge options
    @data = []
  end

  def import
    CSV.foreach @in_file, @options do |row|
      yield row
    end
  end

  def export
    CSV.open @out_file, 'wb' do |csv|
      @data.each { |row| csv << row }
    end
  end
end


class Translator
  include HTTParty
  default_params :source => "en", :target => "ar",
                 :key => "AIzaSyBZqoFfZUVLlMs7--YWOEJR_ylC8gCNtDM"
  format :json


  def self.t(keyword)
    result = get("https://www.googleapis.com/language/translate/v2",
                 :query => {:q => keyword})
    result["data"]["translations"][0]["translatedText"]
  end
end


##############################
# work starts from here
# run:
#
# $ ruby translator.rb INPUT_FILE [OUTPUT_FILE]
##############################

# csv file
file_in = ARGV.shift
if file_in.nil?
  puts "#{$0}: INPUT_FILE [OUTPUT_FILE]"
  exit 1
end

mycsv = MyCSV.new file_in, ARGV.shift
puts mycsv.inspect

mycsv.import do |row|
  puts row["value"]
  row["value"] = Translator.t(row["value"])

  mycsv.data << row
end

mycsv.export
