class RemoveIdFromDocumentsDocuments < ActiveRecord::Migration
  def self.up
  	remove_column :documents_documents, :id
  end

  def self.down
  	add_column :documents_documents, :id, :primary_key
  end
end
