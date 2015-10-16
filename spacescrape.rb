require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'byebug'

require 'yaml'

require 'sqlite3'
require 'sequel'

require 'sidekiq/api'

require 'sinatra/base'
require 'haml'

require 'sidekiq/testing'
Sidekiq::Testing.inline!

Redis.current = Redis.new
DB = Sequel.connect 'sqlite://db/app.sqlite3'

Sequel.extension :migration
Sequel::Migrator.run DB, File.join(File.dirname(__FILE__), 'db', 'migrations')

%w| workers models lib |.each do |dir|
  directory = File.join(File.dirname(__FILE__), dir, '*.rb')
  Dir[directory].each do |file|
    require_relative file
  end
end

def load_data
  starter = YAML.load DATA.read

  # where should we start off looking for things?
  # seed_urls = starter['seed_urls'].map &:freeze

  # What qualifies the page as something we should look for?
  starter['keywords'].each do |keyword|
    tupil = keyword.split('^', 2)

    Keyword.find_or_create keyword: tupil[0] do |model|
      model.weight = tupil[1].to_i || 1
    end
  end

  Setting.find_or_create name: 'play_nice_timeout' do |model|
    model.value = starter['play_nice_timeout'].to_i || 1
  end
end

load_data

class MainApp < Sinatra::Base
  get '/' do
    haml :index
  end

  post '/' do
    ScraperWorker.perform_async params['url'] if params['url']
    redirect to('/')
  end

  run! if app_file == $0
end

__END__
play_nice_timeout: 1

seed_urls:
  - https://en.wikipedia.org/wiki/NASA

keywords:
  - nasa^10
  - space
  - apollo
  - gemini
  - mercury
  - spacecraft
  - space craft
  - soviet union
  - roscosmos
  - star city
  - space shuttle
  - international space station
  - iss
  - soyuz
  - cape canaveral
  - earth
  - galaxy
  - universe
  - nebula
  - planets
  - moon
