class AddSystemAndAliasToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :system, :boolean, :default => false
    add_column :customers, :alias, :integer, :null => true, :default => nil
  end
end
