#ENV['RAILS_ENV'] ||= 'test_mysql'

require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::SQLite3Adapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::SQLite3TestAdapter.new
    @adapter.recreate_test_environment
    @adapter.schema(:items).should be_nil
  end

  describe 'when creating tables with t.foreign_key' do

    # t.foreign_key :farm
    xit 'should understand t.foreign_key' do
      premigrate
      table = "cows"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
    end

    # t.foreign_key :farm, :column => :shearing_farm_id
    xit 'should accept a :column parameter' do
      premigrate
      table = "sheep"
      migrate table
      assert_match(/FOREIGN KEY \(\"shearing_farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
    end

    # t.foreign_key :farm, :dependent => :nullify
    xit 'should accept :dependent => :nullify' do
      premigrate
      table = "bears"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE SET NULL/, schema(table))
    end

    # t.foreign_key :farm, :dependent => :delete
    xit 'should accept :dependent => :delete' do
      premigrate
      table = "elephants"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE CASCADE/, schema(table))
    end
  end

  describe 'when creating tables with t.reference' do

    # t.references :farm, :foreign_key => :true
    xit 'should accept a t.references constraint' do

      premigrate
      table = "pigs"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\)/, schema(table))
    end

    # t.references :farm, :foreign_key => {:dependent => :nullify}
    xit 'should accept :foreign_key => { :dependent => :nullify }' do
      premigrate
      table = "tigers"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE SET NULL/, schema(table))
    end

    # t.references :farm, :foreign_key => {:dependent => :delete}
    xit 'should accept :foreign_key => { :dependent => :delete }' do
      premigrate
      table = "goats"
      migrate table
      assert_match(/FOREIGN KEY \(\"farm_id\"\) REFERENCES \"farms\"\(id\) ON DELETE CASCADE/, schema(table))
    end
  end

end
