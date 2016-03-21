class AddCustomerAndAmountToOldDocs < ActiveRecord::Migration
  def change
    change_table(:old_docs) do |t|
      t.decimal :amount
      t.string :customer
    end
  end
end
