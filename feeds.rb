require 'singleton'
require 'typhoeus'
require 'feedjira'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

class Feeds
    include Singleton
  
    @semaphore = Mutex.new
  
    def self.fetch!
      feeds = []
      hydra = Typhoeus::Hydra.new
      CONFIG['feeds'].each do |feed|
        request = Typhoeus::Request.new(feed, followlocation: true)
        request.on_complete do |response|
          if response.success? && response.body.length > 0
            begin
              feeds << Feedjira.parse(response.body)
            rescue Feedjira::NoParserAvailable
              puts "Failed parsing feed: #{feed}"
            end
          end
        end
        hydra.queue(request)
      end
      hydra.run
      @feeds = feeds
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
        @array_cache = entries.sort_by(&:published).reverse
      end
      @array_cache
    end
  end