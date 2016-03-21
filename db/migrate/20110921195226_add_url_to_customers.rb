class AddUrlToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :url, :string
  end

  def self.down
    remove_column :customers, :url
  end
end
