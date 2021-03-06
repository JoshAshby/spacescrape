source 'https://rubygems.org'
ruby '2.3.0'

gem 'require_all'

# The sadness, but lots of useful helpers
gem 'activesupport', '~> 4', require: 'active_support/all'

# Request making
gem 'faraday'
gem 'faraday_middleware'
gem 'typhoeus'
gem 'robotstxt-parser', require: 'robotstxt'

# Parsing/HTML handling
gem 'nokogiri'
gem 'loofah'
gem 'ruby-readability'

# Text analysis and ML
# gem 'words_counted'
gem 'classifier-reborn', path: '../contrib/classifier-reborn' # Local
# gem 'classifier-reborn', git: 'https://github.com/JoshAshby/classifier-reborn.git' # Git

# Datastore gems
gem 'connection_pool'

## Postgres, ORM
gem 'pg'
gem 'sequel'
gem 'sequel_pg', require: 'sequel'

## Redis Utils
gem 'redis'
gem 'redis-namespace'
gem 'redlock'

## Elasticsearch
# gem 'elasticsearch'
# gem 'elasticsearch-model'

## Neo4j
# gem 'neo4j'

# Communication
## RabbitMQ
gem 'bunny'

# Async Workers
gem 'sidekiq'  # Redis Backed
gem 'sneakers' # RabbitMQ Backed

# Frontend
gem 'sinatra'
# gem 'haml'
# gem 'rabl'

gem 'foreman'

group :doc do
  gem 'yard'
end

group :development, :test do
  gem 'byebug'
  gem 'awesome_print'

  gem 'guard'
  gem 'guard-minitest'
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-stub_any_instance'
  gem 'minitest-focus'
  # gem 'rack-test'
  gem 'simplecov', require: false
end
