module FactoryHelpers
  class CreateCollection < ActiveRecord::Migration
    def self.up
      create_table :collections do |t|
        t.string :name
      end
    end

    def self.down
      drop_table :collections
    end
  end
end

module MigrationFactory

  # Creates a new anonymous migration and puts something into self.up
  # Example:
  #   migration = create_migration do
  #     create_table :items do |t|
  #       t.string :name
  #     end
  #   end
  def create_migration(&blk)
    migration = Class.new(ActiveRecord::Migration)

    # This is the equivalent of 
    # class Foo
    #   def self.up 
    #   end
    # end

    # ActiveSupport 3.0 changed the name to singleton_class
    (migration.respond_to?(:singleton_class) ? migration.singleton_class : migration.metaclass).class_eval do
      define_method(:up, &blk)
    end
    migration
  end

  # Creates a new, anonymous table migration and activates it
  # Example:
  #   migration = create_table do |t|
  #     t.string :name
  #   end
  def create_table(table = :items, opts = {}, &blk)
    migration = create_migration do
      create_table(table, opts, &blk)
    end
    migration.up 
  end

end

module ForeignKeyDefinitionFactory
  def valid_foreign_key_definition(opt = {})
    options = {
      :from_table => 'items',
      :to_table => 'collections'
    }.merge(opt)
  end

  def valid_foreign_key_args(definition)
    from_table = definition.delete(:from_table)
    to_table = definition.delete(:to_table)
    [from_table, to_table, definition]
  end

  def new_foreign_key(opt = {})
    args = valid_foreign_key_args(valid_foreign_key_definition(opt))
    Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(*args)
  end
end
