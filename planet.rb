require 'rack/cache'
require 'sinatra'
require 'yaml'
require 'feedzirra'
require 'builder'
require 'rabl'
require 'raven'

configure :production do
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.excluded_exceptions = ['Sinatra::NotFound']
  end

  use Raven::Rack

  use Rack::Cache,
    :metastore => 'file:tmp/cache/meta',
    :entitystore => 'file:tmp/cache/entity',
    :verbose => true
end

CONFIG = YAML.load_file('config.yml')

Rabl.configure do |config|
  config.escape_all_output = true
  config.include_json_root = false
  config.enable_json_callbacks = true
  config.include_child_root = true
end

class Feeds
  include Singleton

  def self.fetch!
    @feeds = Feedzirra::Feed.fetch_and_parse(CONFIG['feeds'])
    @updated_at = Time.now
  end

  def self.stale?
    @updated_at.nil? || (@updated_at - Time.now) > 15*60 #15 minutes ago
  end

  def self.update
    fetch! if stale?
  end

  def self.entries
    @feeds.values.select{|i| i.is_a?(Feedzirra::Parser::RSS)}.map(&:entries)
  end

  def self.to_a
    if @array_cache.nil? || stale?
      update
      @array_cache = entries.sort_by(&:published).reverse
    end
    @array_cache
  end
end

get '/', :provides => 'html' do
  redirect 'https://github.com/codatory/indyhackers.org-planet'
end

get '/posts.rss' do
  cache_control :public, :max_age => 3600
  @posts = Feeds.to_a
  builder :feed
end

get '/posts.json' do
  cache_control :public, :max_age => 3600
  @posts = Feeds.to_a
  rabl :feed, :format => 'json', :content_type => 'application/json'
end
