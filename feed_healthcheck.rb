require 'typhoeus'
require 'feedjira'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

feeds = []
one_year_ago = Time.now - (365*24*60*60)
errors = {}
Typhoeus::Config.user_agent = "IndyHackers Planet"
hydra = Typhoeus::Hydra.new
CONFIG['feeds'].each do |feed|
  request = Typhoeus::Request.new(feed, followlocation: true)
  request.on_complete do |response|
    if response.success? && response.body.length > 0
      begin
        latest = Feedjira.parse(response.body).entries.sort_by(&:published).last
        if !latest
            puts "No posts found: #{feed}"
            errors[feed] = :length
        elsif latest.published < one_year_ago
            puts "Not updated in over 1 year: #{feed}"
            errors[feed] = :recent
        end
      rescue Feedjira::NoParserAvailable
        puts "Failed parsing feed: #{feed}"
        errors[feed] = :parse
      end
    else
        puts "Failed to load feed: #{feed}"
        errors[feed] = :fetch
    end
  end
  hydra.queue(request)
end
hydra.run

pp errors

exit(1) if errors.size > 0