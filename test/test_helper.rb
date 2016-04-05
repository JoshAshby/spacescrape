ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test/'
    add_filter '.gems/'
    add_filter '.bundle/'

    add_filter 'cache/'
    add_filter 'db/'

    add_filter 'config/'

    minimum_coverage 50
    refuse_coverage_drop

    command_name 'Minitest'

    add_group 'Initializers', 'config/initializers'
    add_group 'Models',       'app/models'
    add_group 'Workers',      'app/workers'
    add_group 'Subscribers',  'app/subscribers'
    add_group 'Lib',          'lib'
  end
end

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'minitest/autorun'
require 'minitest/stub_any_instance'

require_relative '../spacescrape.rb'
require_rel 'mocks/', 'helpers/'

require 'sidekiq/testing'
Sidekiq::Testing.fake!    # fake is the default mode
Sidekiq::Testing.disable!

module SidekiqMinitestSupport
  def after_teardown
    Sidekiq::Worker.clear_all
  end
end

class SidekiqTestCase
  include SidekiqMinitestSupport
end
