ENV['RAILS_ENV'] ||= 'mysql'
require File.dirname(__FILE__) + '/test_helper'
require "foreigner/connection_adapters/mysql_adapter"

class MysqlAdapterTest < ActiveRecord::TestCase
  include Foreigner::ConnectionAdapters::MysqlAdapter

  # t.foreign_key :farm
  def test_adding_cows_to_the_farm_with_t_dot_foreign_key_farm
    premigrate
    table = "cows"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\)/, schema(table))
  end

  # t.foreign_key :farm, :column => :shearing_farm_id
  def test_adding_sheep_to_the_farm_with_t_dot_foreign_key_farm_column_id_shearing_farm_id
    premigrate
    table = "sheep"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`shearing_farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\)/, schema(table))
  end

  # t.foreign_key :farm, :dependent => :nullify
  def test_adding_bears_to_the_farm_with_t_dot_foreign_key_farm_dependent_nullify
    premigrate
    table = "bears"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE SET NULL/, schema(table))
  end

  # t.foreign_key :farm, :dependent => :delete
  def test_adding_elephants_to_the_farm_with_t_dot_foreign_key_farm_dependent_delete
    premigrate
    table = "elephants"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE CASCADE/, schema(table))
  end

  def test_adding_pigs_to_the_farm_with_t_dot_references_farm_foreign_key_true
    premigrate
    table = "pigs"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\)/, schema(table))
  end

  # t.references :farm, :foreign_key => {:dependent => :nullify}
  def test_adding_tigers_to_the_farm_with_t_dot_references_farm_foreign_key_dependent_delete
    premigrate
    table = "tigers"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE SET NULL/, schema(table))
  end

  # t.references :farm, :foreign_key => {:dependent => :delete}
  def test_adding_goats_to_the_farm_with_t_dot_references_farm_foreign_key_dependent_delete
    premigrate
    table = "goats"
    migrate table
    assert_match(/FOREIGN KEY\s*\(\`farm_id\`\) REFERENCES \`farms\`\s*\(\`id\`\) ON DELETE CASCADE/, schema(table))
  end

  def test_add_without_options
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies)
    )
  end

  def test_add_with_name
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :name => 'favorite_company_fk')
    )
  end

  def test_add_with_column
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_last_employer_id_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :column => 'last_employer_id')
    )
  end

  def test_add_with_column_and_name
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :column => 'last_employer_id', :name => 'favorite_company_fk')
    )
  end

  def test_add_with_delete_dependency
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE CASCADE",
      add_foreign_key(:employees, :companies, :dependent => :delete)
    )
  end

  def test_add_with_nullify_dependency
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE SET NULL",
      add_foreign_key(:employees, :companies, :dependent => :nullify)
    )
  end

  def test_remove_by_table
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_company_id_fk`",
      remove_foreign_key(:suppliers, :companies)
    )
  end

  def test_remove_by_name
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `belongs_to_supplier`",
      remove_foreign_key(:suppliers, :name => "belongs_to_supplier")
    )
  end

  def test_remove_by_column
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_ship_to_id_fk`",
      remove_foreign_key(:suppliers, :column => "ship_to_id")
    )
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

    def premigrate
      @database = ActiveRecord::Base.configurations['mysql']['database']
      ActiveRecord::Base.connection.drop_database(@database)
      ActiveRecord::Base.connection.create_database(@database)
      ActiveRecord::Base.connection.reset!
      migrate "farms"
    end

    def schema(table_name)
        ActiveRecord::Base.connection.select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]
    end

    def migrate(table_name)
      migration = "create_#{table_name}"
      require "app_root/db/migrate/#{migration}"
      migration.camelcase.constantize.up
      assert ActiveRecord::Base.connection.table_exists?(table_name)
    end

end

