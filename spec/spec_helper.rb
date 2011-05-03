
require 'rubygems'

require 'rspec'

require 'active_support'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'
require "foreigner/connection_adapters/postgresql_adapter"
require "foreigner/connection_adapters/mysql_adapter"
require "foreigner/connection_adapters/sqlite3_adapter"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run :focus => true
  config.filter_run_excluding :external => true
  config.run_all_when_everything_filtered = true
end

# CONFIGURATIONS defined in support/adapter_helper.rb

# Turn this on for debugging
ActiveRecord::Migration.verbose = false


