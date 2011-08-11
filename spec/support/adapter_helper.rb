if ENV['TRAVIS']
  CONFIGURATIONS = {
    :postgresql => {
      :adapter => "postgresql",
      :username => "postgres",
      :password => "",
      :database => "test",
      :min_messages => "ERROR" },
    :postgresql_admin => {
      :adapter => "postgresql",
      :username => "postgres",
      :password => "",
      :database => "admin",
      :min_messages => "ERROR"
      }, 
    # :postgresql_admin is used to connect in; :postgresql is used to actually test the migrations
    :mysql => {
      :adapter => 'mysql',
      :host => 'localhost',
      :username => 'root',
      :database => 'test' }, 
    :sqlite3 => {
      :adapter => "sqlite3",
      :database => ":memory:" } }
else 
  CONFIGURATIONS = {
    :postgresql => {
    :adapter => "postgresql",
    :username => "root",
    :password => "",
    :database => "test_foreigner_gem",
    :min_messages => "ERROR"
  },
    :postgresql_admin => {
      :adapter => "postgresql",
      :username => "root",
      :password => "",
      :database => "test",
      :min_messages => "ERROR" }, 
  # :postgresql_admin is used to connect in; :postgresql is used to actually test the migrations
    :mysql => {
      :adapter => 'mysql',
      :host => 'localhost',
      :username => 'root',
      :database => 'foreigner_test' }, 
    :sqlite3 => {
      :adapter => "sqlite3",
      :database => ":memory:" }
  }
end

module AdapterHelper
  module AdapterTestHarness
    def recreate_test_environment(env)
      ActiveRecord::Base.establish_connection(CONFIGURATIONS[env])

      @database = CONFIGURATIONS[env][:database]
      ActiveRecord::Base.connection.drop_database(@database)
      ActiveRecord::Base.connection.create_database(@database)
      ActiveRecord::Base.connection.reset!

      FactoryHelpers::CreateCollection.up
    end

    def schema(table_name)
      raise 'This method must be overridden'
    end

    def foreign_keys(table)
      ActiveRecord::Base.connection.foreign_keys(table)
    end

    private

    def execute(sql, name = nil)
      sql
    end

    def quote_column_name(name)
      "`#{name}`"
    end

    def quote_table_name(name)
      quote_column_name(name).gsub('.', '`.`')
    end

  end

  class PostgreSQLTestAdapter
    include Foreigner::ConnectionAdapters::PostgreSQLAdapter
    include AdapterTestHarness

    def recreate_test_environment
      ActiveRecord::Base.establish_connection(CONFIGURATIONS[:postgresql_admin])
      @database = CONFIGURATIONS[:postgresql][:database]

      ActiveRecord::Base.connection.drop_database(@database)
      ActiveRecord::Base.connection.create_database(@database)

      ActiveRecord::Base.connection.disconnect!
      ActiveRecord::Base.establish_connection(CONFIGURATIONS[:postgresql])

      FactoryHelpers::CreateCollection.up
    end
  end

  class MySQLTestAdapter 
    include Foreigner::ConnectionAdapters::MysqlAdapter
    include AdapterTestHarness

    def schema(table_name)
      ActiveRecord::Base.connection.select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]
    end

    def recreate_test_environment
      super(:mysql)
    end
  end

  class SQLite3TestAdapter 
    include Foreigner::ConnectionAdapters::SQLite3Adapter
    include AdapterTestHarness

    def schema(table_name) ActiveRecord::Base.connection.select_value %{
        SELECT sql
        FROM sqlite_master
        WHERE name = '#{table_name}'
      }
    end

    def foreign_keys(table)
      raise "Unimplemented"
    end

    def recreate_test_environment
      ActiveRecord::Base.establish_connection(CONFIGURATIONS[:sqlite3])

      @database = CONFIGURATIONS[:sqlite3][:database]
      #ActiveRecord::Base.connection.drop_database(@database)
      #ActiveRecord::Base.connection.create_database(@database)
      ActiveRecord::Base.connection.reset!

      FactoryHelpers::CreateCollection.up
    end
  end


end
