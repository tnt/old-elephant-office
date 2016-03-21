# coding: utf-8
class EmailAddressSpecific < ActiveRecord::Base
  belongs_to :contactable, :foreign_key => :email_address_id
  #validates_uniqueness_of :email
  validate do |rec|
    existing = EmailAddress.where('"outdated"=false AND lower("email_address_specifics"."email") = ?', rec.email.downcase).first
    if existing && existing.specific != rec
      errors.add(:email, "existiert bereits für Kunde #{existing.customer.name}.")
    end
  end
end
