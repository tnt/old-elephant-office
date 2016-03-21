class AddPhoneticToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :name_phonetic_codes, :string, :null => false, :default => ''
    Customer.all.each do |c|
      c.update_attribute :name_phonetic_codes, c.name.phonetic_codes
    end
  end

  def self.down
    remove_column :customers, :name_phonetic_codes
  end
end
