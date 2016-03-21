class AddAlternatePartToEmailAttachments < ActiveRecord::Migration
  def self.up
  	add_column :email_attachments, :alternate_part, :boolean, :null => false, :default => false
  end

  def self.down
  	remove_column :email_attachments, :alternate_part
  end
end
