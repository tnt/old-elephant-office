# coding: utf-8
class DocumentAlias < Document
  include UserInfo
  attr_accessible :alias_for, :address_id
  belongs_to :docalias_contactable, :foreign_key => :address_id
  belongs_to :document, :foreign_key => :alias_for
  
  delegate :customer, :to => :docalias_contactable
  #before_create do
  #end

end

