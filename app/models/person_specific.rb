# coding: utf-8
class PersonSpecific < ActiveRecord::Base
  belongs_to :contactable, :foreign_key => :person_id
end
