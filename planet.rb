require 'rack/cache'
require 'sinatra'
require 'yaml'
require 'feedzirra'
require 'builder'
require 'rabl'

CONFIG = YAML.load_file('config.yml')
FEEDS  = Feedzirra::Feed.fetch_and_parse(CONFIG['feeds'])

use Rack::Cache,
  :metastore => 'file:tmp/cache/meta',
  :entitystore => 'file:tmp/cache/entity',
  :verbose => true

Rabl.configure do |config|
  config.escape_all_output = true
  config.include_json_root = false
  config.enable_json_callbacks = true
  config.include_child_root = true
end

def post_array
  Feedzirra::Feed.update(FEEDS.values)
  FEEDS.values.map(&:entries).flatten.sort_by(&:published).reverse
end

get '/', :provides => 'html' do
  erb :index
end

get '/posts.rss' do
  cache_control :public, :max_age => 3600
  @posts = post_array
  builder :feed
end

get '/posts.json' do
  cache_control :public, :max_age => 3600
  @posts = post_array
  rabl :feed, :format => 'json', :content_type => 'application/json'
end
