class MakeDocaliasContableRecordsForAllCustomers < ActiveRecord::Migration
  def up
    Customer.all.each do |c|
      c.contactables << DocaliasContactable.new(:sex => 'male')
    end
  end

  def down
    DocaliasContactable.delete_all
  end
end
