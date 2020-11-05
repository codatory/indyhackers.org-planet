require 'rack/cache'
require 'sinatra'
require 'builder'
require 'rabl'
require 'raven'
require 'sinatra/cross_origin'
require './feeds'

configure do
  enable :cross_origin
end
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

Rabl.configure do |config|
  config.escape_all_output = true
  config.include_json_root = false
  config.enable_json_callbacks = true
  config.include_child_root = true
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

get '/feeds.opml' do
  cache_control :public, :max_age => 3600
  @feeds = Feeds.feed_meta
  builder :opml
end