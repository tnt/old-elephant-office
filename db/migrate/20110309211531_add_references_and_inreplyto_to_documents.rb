class AddReferencesAndInreplytoToDocuments < ActiveRecord::Migration
  def self.up
 		add_column :documents, :in_reply_to, :string, :null => true, :default => nil
 		add_column :documents, :references, :text, :null => true, :default => nil
 end

  def self.down
 		remove_column :documents, :in_reply_to
 		remove_column :documents, :references
  end
end
