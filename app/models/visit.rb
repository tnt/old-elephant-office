# coding: utf-8
class Visit < Talk
  # is_foreign false => 'we visited customer', true => 'customer visited us'
  #belongs_to :contactable, :foreign_key => :address_id
  #alias :contactable, :person
end

