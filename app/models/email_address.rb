# coding: utf-8
class EmailAddress < Contactable
  relate_to_specific

  delegate :email, :to => :specific
  delegate :unassigned_customer, :to => :customer

  has_many :emails, :order => 'date desc', :foreign_key => :address_id

  scope :current_email_addresses, :conditions => { :outdated => false }, 
                :order => 'id desc'
  scope :oudated_email_addresses, :conditions => { :outdated => true }, 
                :order => 'id desc'
  
  def email_address_complete
    #full_name = [title,firstname,name].reject {|i| i.nil?||i.empty?}.join ' '
    full_name.empty? ? email : "#{full_name} <#{email}>"
  end
end
