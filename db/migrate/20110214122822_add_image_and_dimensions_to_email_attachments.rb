class AddImageAndDimensionsToEmailAttachments < ActiveRecord::Migration
  def self.up
    add_column :email_attachments, :image, :boolean, :null => false, :default => false
    add_column :email_attachments, :dimensions, :string, :null => true
  end

  def self.down
    remove_column :email_attachments, :image
    remove_column :email_attachments, :dimensions
  end
end
