class AddMarkupToDocuments < ActiveRecord::Migration
  def change
    change_table(:documents) do |t|
      t.string :markup, :default => ''
    end
  end
end
