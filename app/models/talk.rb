# coding: utf-8
class Talk < Document
  after_initialize {self.markup = 'markdown' if self.markup.empty? && not(self.persisted?)}

  belongs_to :phone_number, :foreign_key => :address_id
  belongs_to :person, :foreign_key => :address_id

  def main_type
    'Talk'
  end

  def haml_object_ref
    'talk'
  end
end
