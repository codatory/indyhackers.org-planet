require 'rack/cache'
require 'sinatra'
require 'yaml'
require 'feedzirra'
require 'builder'

CONFIG = YAML.load(File.new('config.yml'))

FEEDS = Feedzirra::Feed.fetch_and_parse(CONFIG['feeds'])

use Rack::Cache,
  :metastore => 'file:tmp/cache/meta',
  :entitystore => 'file:tmp/cache/entity',
  :verbose => true

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
