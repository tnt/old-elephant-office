class AddAliasForToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :alias_for, :integer, :null => true, :default => nil
  end
end
