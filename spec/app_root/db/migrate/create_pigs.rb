class CreatePigs < ActiveRecord::Migration
  def self.up
    create_table :pigs do |t|
      t.string :name
      t.references :farm, :foreign_key => true
    end
  end

  def self.down
    drop_table :pigs
  end
end

