class AddFilesizeToEmailAttachments < ActiveRecord::Migration
  def self.up
  	add_column :email_attachments, :file_size, :integer, :null => true
  end

  def self.down
  	remove_column :email_attachments, :file_size
  end
end
