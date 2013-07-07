#!/usr/local/ruby

require 'yaml'
require 'feedbag'
require 'feedzirra'

CONFIG = YAML.load_file('config.yml')

url = ARGV.pop

puts "Attempting to find RSS Feed for #{url}"

feed = Feedbag.find(url).first

puts "Found feed at #{feed}"
puts "Attempting to read feed"

latest = Feedzirra::Feed.fetch_and_parse(feed).entries.first

puts "Here's the latest post..."
puts "Title:   #{latest.title}"
puts "URL:     #{latest.url}"
puts "--------------------------"
puts (latest.content || latest.summary).gsub(/<\/?[a-zA-Z0-9 ]*\/?>/, '')[0..200]

CONFIG['feeds'] << feed
CONFIG['feeds'].sort!
CONFIG['feeds'].uniq!

File.open('config.yml', 'w') do |out|
  YAML.dump(CONFIG, out)
end
