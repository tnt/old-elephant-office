class CreateOldDocs < ActiveRecord::Migration
  def change
    create_table :old_docs do |t|
      t.datetime :date
      t.string :filename
      t.string :author
      t.text :comment

      t.timestamps
    end
  end
end
