class AddSeenToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :seen, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :documents, :seen
  end
end
