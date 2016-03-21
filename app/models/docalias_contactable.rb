# coding: utf-8
class DocaliasContactable < Contactable
  #relate_to_specific

  has_many :document_aliases, :order => 'date desc', :foreign_key => :address_id
  #delegate :aliased_documents, :to => :document_aliases
end
