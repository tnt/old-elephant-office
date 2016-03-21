class AddUidToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :imap_uid, :integer
    add_column :documents, :imap_server, :integer
  end

  def self.down
    remove_column :documents, :imap_uid
    remove_column :documents, :imap_server
  end
end
