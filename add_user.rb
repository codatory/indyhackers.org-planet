#!/usr/local/ruby

require 'yaml'
require 'feedbag'
require 'feedjira'

CONFIG = YAML.load_file('config.yml')

url = ARGV.pop

if url[0] != 'h'
  url = "http://#{url}"
end

puts "Attempting to find RSS Feed for #{url}"

feed = Feedbag.find(url).first
raise "No feed found!" unless feed

puts "Found feed at #{feed}"
puts "Attempting to read feed"

latest = Feedjira.parse(URI.open(feed).read).entries.sort_by(&:published).last

puts "Here's the latest post..."
puts "Title:   #{latest.title}"
puts "URL:     #{latest.url}"
puts "Date:    #{latest.published}"
puts "--------------------------"
puts (latest.content || latest.summary).gsub(/<\/?[a-zA-Z0-9 ]*\/?>/, '')[0..200]

raise "Latest post is too old!" if latest.published < Time.now - (365*24*60*60)

CONFIG['feeds'] << feed
CONFIG['feeds'].sort!
CONFIG['feeds'].uniq!

File.open('config.yml', 'w') do |out|
  YAML.dump(CONFIG, out)
end
