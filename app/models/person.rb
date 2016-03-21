# coding: utf-8
class Person < Contactable
  relate_to_specific

  has_many :visits, :order => 'date desc', :foreign_key => :address_id

  def skip_validation
    true
  end
end
