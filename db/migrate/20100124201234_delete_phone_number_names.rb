class DeletePhoneNumberNames < ActiveRecord::Migration
  def self.up
    PhoneNumber.all.each do |pn|  
      ma = pn.customer.addresses[0]
      next unless ma
      pn.update_attributes({:title => '', :firstname => '', :name => ''}) if ( pn.name == ma.name && pn.firstname == ma.firstname)
    end
  end

  def self.down
  end
end
