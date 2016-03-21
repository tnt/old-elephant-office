# coding: utf-8
class Customer < ActiveRecord::Base
  default_scope order(:name)
  has_many :contactables, :order => 'type asc, contactables.id desc', :dependent => :destroy
  accepts_nested_attributes_for :contactables, :allow_destroy => true
  delegate :current_contactables, :to => :contactables
  delegate :outdated_contactables, :to => :contactables
  has_many :addresses, :order => 'contactables.id desc', :dependent => :destroy
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  delegate :current_addresses, :to => :addresses
  has_many :email_addresses, :order => 'contactables.id desc', :dependent => :destroy
  accepts_nested_attributes_for :email_addresses, :allow_destroy => true
  delegate :current_email_addresses, :to => :email_addresses
  has_many :phone_numbers, :order => 'contactables.id desc', :dependent => :destroy
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  delegate :current_phone_numbers, :to => :phone_numbers
  delegate :outdated_phone_numbers, :to => :phone_numbers
  has_many :people, :order => 'contactables.id desc', :dependent => :destroy
  accepts_nested_attributes_for :people, :allow_destroy => true
  delegate :current_people, :to => :people
  has_many :docalias_contactables, :dependent => :destroy
  has_many :documents, :through => :contactables, :order => 'date desc'  #, :order => 'coalesce(date, \'9999-12-31\') desc'
  delegate :non_aliases, :to => :documents
  #delegate :document_aliases, :to => :docalias_contactable
  has_many :document_aliases, :through => :docalias_contactables
  has_many :papers, :through => :addresses, :order => 'date desc'
  delegate :invoices, :open_invoices, :to => :papers
  has_many :emails, :through => :email_addresses, :order => 'date desc'
  delegate :attachables, :to => :documents
  
  has_many :aliases, :class_name => 'Customer', :foreign_key => :alias, :autosave => true, :dependent => :destroy
  accepts_nested_attributes_for :aliases, :allow_destroy => true

  #delegate :aliased_documents, :to => :docalias_contactables
  #has_many :contents, :through => { :addresses => :papers }, :order => 'date desc' # doesn't work
  #has_many :contents, :through => :papers, :source => :contents , :order => 'date desc' # doesn't work
  #delegate :contents, :to => :documents # also doesn't work
  #delegate :contents, :to => 'addresses.papers' # also doesn't work
  #has_many :contents, :through => 'addresses.papers' # also doesn't work
  
  scope :non_system, where(:system => false)
  def self.items_page customer, limit
    non_system.where(['"customers"."name" < ?', customer.name]).count.to_i / limit + 1
  end

  def documents_of_others
    Document.non_aliases.where('address_id not IN (?)', contactable_ids).order('id desc').limit(20+aliased_documents.count) - aliased_documents
  end
  
  def aliased_documents
    @aliased_documents ||= document_aliases.map {|doc| doc.document}
  end

  validates_presence_of :name
  before_save {self.name_phonetic_codes = self.name.phonetic_codes}
  after_create { self.contactables << DocaliasContactable.new(:sex => 'male') }

  def docalias_contactable
    docalias_contactables.first
  end

  def doc_aliased_customers
    (Customer.where(:id => (DocaliasContactable.select(:customer_id)\
          .where(:id => DocumentAlias.select(:address_id)\
          .where(:alias_for => self.document_ids) ).map {|c| c.customer_id}) )\
          +  self.document_aliases.map {|d| d.document.contactable.customer}).uniq\
          .sort {|a,b| a.name.upcase <=> b.name.upcase}
  end

  def invoice_address
    #logger.info "self.addresses.length: '#{self.addresses.length}'"
    self.addresses.detect {|addr| addr.invoice_address} || self.addresses[0] # detect is NOT an alias for find here 
    #fire_log 'yeah!'
  end
  
  def unassigned_customer
    self.id === Elph[:imap_settings][:un_assigned_customer_id]
  end
  
  def self.search(search, phonetic)
    if search
      if phonetic
        non_system.where(['"customers"."name_phonetic_codes" ilike ?', "%#{search.phonetic_codes}%"])
      else
        non_system.where(['"customers"."name" ilike ?', "%#{search}%"])
      end
    else
      self.scoped
    end
  end
  
  def sane_url
    self.url.sub(/^(?!https?:\/\/)/, 'http://').sub(/^https?:\/\/[-A-Za-z.]+$/, '\0/')
  end
end
