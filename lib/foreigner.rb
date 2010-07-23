require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/semantics/sql_2003'
require 'foreigner/schema_dumper'

module Foreigner
  mattr_accessor :adapters
  self.adapters = {}

  class << self
    def register(adapter_name, file_name)
      adapters[adapter_name] = file_name
    end
  
    def load_adapter!
      if adapters.key?(configured_adapter)
        require adapters[configured_adapter]
      end
    end
    
    def configured_adapter
      ActiveRecord::Base.connection.adapter_name.downcase
    end
    
    def on_load(&block)
      if defined?(Rails) && Rails.version >= '3.0'
        ActiveSupport.on_load :active_record do
          ActiveSupport.on_load :before_initialize do
            unless ActiveRecord::Base.connected?
              ActiveRecord::Base.configurations = Rails.application.config.database_configuration
              ActiveRecord::Base.establish_connection
            end
          end
          block.call
        end
      else
        yield
      end
    end
  end
end

Foreigner.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'sqlite3', 'foreigner/connection_adapters/sqlite3_adapter'
Foreigner.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

Foreigner.on_load do
  module ActiveRecord
    module ConnectionAdapters
      include Foreigner::ConnectionAdapters::SchemaStatements
      include Foreigner::ConnectionAdapters::SchemaDefinitions
    end

    SchemaDumper.class_eval do
      include Foreigner::SchemaDumper
    end
  end
  
  Foreigner.load_adapter! if defined?(Rails) # Audo-load if within Rails
end
