ENV["RAILS_ENV"] = "test"
require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/test_case'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/mysql_adapter'
require 'foreigner'

