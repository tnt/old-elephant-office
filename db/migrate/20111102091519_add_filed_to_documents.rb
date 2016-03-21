class AddFiledToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :filed, :boolean, :default => false
    add_column :documents, :system, :boolean, :default => false
  end
end
