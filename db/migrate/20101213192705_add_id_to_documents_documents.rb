class AddIdToDocumentsDocuments < ActiveRecord::Migration
  def self.up
  	add_column :documents_documents, :id, :primary_key
  end

  def self.down
  	remove_column :documents_documents, :id
  end
end
