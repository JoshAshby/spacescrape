if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test/'
    add_filter '.gems/'
    add_filter '.bundle/'
    add_filter 'cache/'
    add_filter 'db/'

    command_name 'Mintest'

    add_group 'Initializers', 'config/initializers'
    add_group 'Models',       'app/models'
    add_group 'Workers',      'app/workers'
    add_group 'Sinatra',      'app/sinatra'
    add_group 'Lib',          'lib'
  end
end

ENV['RACK_ENV'] = 'test'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'minitest/autorun'
require 'rack/test'

require_relative '../spacescrape.rb'

require 'sidekiq/testing'
Sidekiq::Testing.fake!    # fake is the default mode
Sidekiq::Testing.disable!

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
  end
end

class MiniTest::Test
  include SidekiqMinitestSupport
end
