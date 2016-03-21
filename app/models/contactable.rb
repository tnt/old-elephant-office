# coding: utf-8
class Contactable < ActiveRecord::Base

  def self.relate_to_specific
    class_eval do
      has_one :specific, :class_name => "#{self.name}Specific", :autosave => true, :dependent => :delete
      accepts_nested_attributes_for :specific, :allow_destroy => true
      default_scope :include => :specific
      validates_presence_of :specific, :unless => :skip_validation
    end
  end

  before_destroy :outdate_or_destroy

  belongs_to :customer

  has_many :documents, :order => 'date desc', :foreign_key => :address_id, :dependent => :destroy

  validates_inclusion_of :sex, :in => Elph[:sex_kinds]

  #scope :current_contactables, where(:outdated => false).order('type asc, contactables.id desc')
  scope :current_contactables, where(:outdated => false).where(['type !=?', 'DocaliasContactable']).order('type asc, contactables.id desc')
  scope :outdated_contactables, where(:outdated => true).order('type asc, contactables.id desc')

  def mark_outdated
    self.update_attribute :outdated, true
    attributes = {} # for updating the html via the .rjs-template - like {'3'=>{'invoice_address'=>true,'outdated'=>false},'32'=>{'delivery_address'=>false}}
    attributes[self.id.to_s] = {:outdated => true }
    if self.is_a?(Address) && self.customer.current_addresses.count > 0
      first_address = self.customer.current_addresses[0]
      attributes[first_address.id.to_s] = {}
      %w(invoice_address delivery_address).each do |att|
        if self.send(att)
          self.update_attribute(att, false)
          attributes[self.id.to_s][att] = false
          first_address.update_attribute(att, true)
          attributes[first_address.id.to_s][att] = true
        end
      end
    end
    return attributes
  end

  def outdate_or_destroy
    # tct_logger.info "self.documents.count: #{self.documents.count}"
    if self.documents.count > 0
      mark_outdated
      return false
    end
  end

  def skip_validation
    false
  end


  def cname #common name
    self.name.blank? ? self.customer.name : self.name
  end

  def full_name
    [self.title, self.firstname, self.name].reject {|p| p.blank?}.join ' '
  end
end
