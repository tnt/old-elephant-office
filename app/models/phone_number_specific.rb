# coding: utf-8
class PhoneNumberSpecific < ActiveRecord::Base
  # extend PhoneNumberNormize
  include PhoneNumberNormize
  
  belongs_to :contactable, :foreign_key => :phone_number_id
  
  validates_presence_of :number
  
  before_save do
    self.norm_number = _normize_number(self.number)
  end

  delegate :customer, :to => :contactable

  def self.search(num_str, full_number=false)
    if full_number
      where(norm_number: _normize_number(num_str))
    else
      where(['"phone_number_specifics"."norm_number" like ?', "%#{_strip_deco(num_str)}%"])
    end
  end
end
