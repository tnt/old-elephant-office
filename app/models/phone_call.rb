# coding: utf-8
class PhoneCall < Talk
  belongs_to :phone_number, :foreign_key => :address_id
  # is_foreign false => 'we called customer', true => 'customer called us'
  alias contactable phone_number
end
