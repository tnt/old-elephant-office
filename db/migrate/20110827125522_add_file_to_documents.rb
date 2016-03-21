class AddFileToDocuments < ActiveRecord::Migration
  # add "file"-column for uploaded "ExternalPaper"-documents
  def self.up
    add_column :documents, :file, :string
  end

  def self.down
    remove_column :documents, :file
  end
end
