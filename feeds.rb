require 'singleton'
require 'typhoeus'
require 'feedjira'
require 'yaml'

CONFIG = YAML.load_file('config.yml')
Typhoeus::Config.user_agent = "IndyHackers Planet"

class Feeds
    include Singleton
  
    @semaphore = Mutex.new
    @feeds = []
    @feed_meta = []
  
    def self.fetch!
      feeds = []
      feed_meta = []
      hydra = Typhoeus::Hydra.new
      CONFIG['feeds'].each do |feed|
        request = Typhoeus::Request.new(feed, followlocation: true)
        request.on_complete do |response|
          if response.success? && response.body.length > 0
            begin
              parsed_feed = Feedjira.parse(response.body)
              feeds << parsed_feed
              feed_meta << {
                title: parsed_feed.title,
                xml_url: parsed_feed.feed_url || feed,
                html_url: parsed_feed.url,
                description: parsed_feed.description,
                type: "rss",
                version: "RSS2"
              }
            rescue Feedjira::NoParserAvailable
              puts "Failed parsing feed: #{feed}"
            end
          end
        end
        hydra.queue(request)
      end
      hydra.run
      @feeds = feeds
      @feed_meta = feed_meta
      @updated_at = Time.now
    end
  
    def self.stale?
      @updated_at.nil? || (@updated_at - Time.now) > 15*60 #15 minutes ago
    end
  
    def self.update
      @semaphore.synchronize do
        fetch! if stale?
      end
    end
  
    def self.entries
      @feeds.map(&:entries).flatten
    end
  
    def self.to_a
      if @array_cache.nil? || stale?
        update
        one_year_ago = Time.now - (365*24*60*60)
        @array_cache = entries.sort_by(&:published).reject{|e| e.published < one_year_ago}.reverse
      end
      @array_cache
    end

    def self.feed_meta
      update
      @feed_meta
    end
  end