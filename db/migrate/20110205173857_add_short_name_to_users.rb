class AddShortNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :short_name, :string, :limit => 20
  end

  def self.down
    remove_column :users, :short_name
  end
end
