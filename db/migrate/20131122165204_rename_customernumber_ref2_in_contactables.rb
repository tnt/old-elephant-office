class RenameCustomernumberRef2InContactables < ActiveRecord::Migration
  def up
    rename_column :contactables, :cust_num, :cust_ref1
    rename_column :contactables, :cust_ref, :cust_ref2
  end

  def down
    rename_column :contactables, :cust_ref1, :cust_num
    rename_column :contactables, :cust_ref2, :cust_ref
  end
end
