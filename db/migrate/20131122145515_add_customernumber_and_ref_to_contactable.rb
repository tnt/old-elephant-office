class AddCustomernumberAndRefToContactable < ActiveRecord::Migration
  def change
    change_table(:contactables) do |t|
      t.string :cust_num
      t.string :cust_ref
    end
  end
end
