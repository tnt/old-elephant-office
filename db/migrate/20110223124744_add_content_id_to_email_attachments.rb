class AddContentIdToEmailAttachments < ActiveRecord::Migration
  def self.up
    add_column :email_attachments, :content_id, :string, :null => true, :default => nil
    add_column :email_attachments, :inline, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :email_attachments, :content_id
    remove_column :email_attachments, :inline
  end
end
