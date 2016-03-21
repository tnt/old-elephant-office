class AddSelfGeneratedEmailToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :self_generated_email, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :documents, :self_generated_email
  end
end
