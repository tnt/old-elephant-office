# coding: utf-8
class Address < Contactable
  relate_to_specific

  validates_presence_of :name

  has_many :papers, :order => 'date desc'
  
  delegate :line2, :line3, :street, :number, :zip, :city, :country, :state, :delivery_address, :invoice_address=, :delivery_address=, :invoice_address, :to => :specific 
  
  scope :current_addresses, :conditions => { :outdated => false }, 
                :order => 'id desc'
  scope :oudated_addresses, :conditions => { :outdated => true }, 
                :order => 'id desc'

  def set_delivery_invoice att
    attributes = {} # for updating the html via the .rjs-template - like {'3'=>{'invoice_address'=>true,'outdated'=>false},'32'=>{'delivery_address'=>false}}
    self.customer.current_addresses.each do |addr| 
      attributes[addr.id.to_s] = {}
      attribute = addr == self
      attributes[addr.id.to_s][att] = attribute unless addr.outdated
      # addr.send("#{params[:attribute]}=", attribute)
      addr.update_attribute att.to_sym, attribute
      logger.info 'loop excuted once ' + addr.id.to_s
    end
    return attributes
  end
  def to_string line_end="\n"
    addr = [ [self.title,self.firstname,self.name].reject {|i| i.blank?}.join(' ') ]
    addr += [ self.line2, self.line3 ]
    addr << "#{self.street} #{self.number}"
    addr << "#{self.zip} #{self.city}"
    addr << self.country
    addr.reject {|i| i.blank?}.join line_end
  end
end
