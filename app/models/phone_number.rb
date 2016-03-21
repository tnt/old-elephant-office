# coding: utf-8
class PhoneNumber < Contactable
  relate_to_specific

  delegate :number, :norm_number, :kind, :to => :specific

  has_many :talks, :order => 'date desc', :foreign_key => :address_id
  has_many :phone_calls, :order => 'date desc', :foreign_key => :address_id

  scope :current_phone_numbers, where(:outdated => false).order('phone_number_specifics.kind asc, contactables.id desc')
  scope :outdated_phone_numbers, where(:outdated => true).order('phone_number_specifics.kind asc, contactables.id desc')
end
