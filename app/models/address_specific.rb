# coding: utf-8
class AddressSpecific < ActiveRecord::Base
	belongs_to :contactable, :foreign_key => :address_id
	validates_length_of :line2, :maximum => 60
	validates_length_of :line3, :maximum => 60
end
