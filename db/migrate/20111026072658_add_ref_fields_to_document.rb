class AddRefFieldsToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :your_message, :string, :null => false, :default => ''
    add_column :documents, :your_sign, :string, :null => false, :default => ''
    add_column :documents, :our_sign, :string, :null => false, :default => ''
    add_column :documents, :our_contact, :text, :null => false, :default => ''
  end
end
