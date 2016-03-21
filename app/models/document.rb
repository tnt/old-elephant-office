# coding: utf-8
class Document < ActiveRecord::Base
  include UserInfo

  attr_accessible :address_id, :based_on, :date, :value, :remark, :kind, :user_id, :last_modified_by, :created_at, :updated_at, :state, :signed_by, :scale, :invoice_number, :subject, :tax_rate, :type, :message, :message_id, :sent, :is_foreign, :realization_from, :realization_to, :imap_uid, :imap_server, :seen, :self_generated_email, :in_reply_to, :references, :file, :your_sign, :our_sign, :your_message, :our_contact, :markup

  before_create :set_user_id
  before_save { self.last_modified_by = current_user }
  after_update { self.aliases.each {|a| a.update_attribute(:date, self.date)}}

  belongs_to :address
  belongs_to :contactable, :foreign_key => :address_id
  delegate :customer, :to => :contactable
  belongs_to :user
  belongs_to :modifier, :class_name => "User", :foreign_key => "last_modified_by"
  belongs_to :signer, :class_name => "User", :foreign_key => "signed_by"
  has_and_belongs_to_many :linkees, :class_name => "Document", :foreign_key => "linker_id",
    :association_foreign_key => 'linkee_id'
  has_and_belongs_to_many :linkers, :class_name => "Document", :foreign_key => "linkee_id",
    :association_foreign_key => 'linker_id'
  #has_many :based_ons, :class_name => "Document", :foreign_key => "id",
  #	:association_foreign_key => 'based_on'
  #has_many :document_aliases, :class_name => "Document", :association_foreign_key => :alias_for
  has_many :aliases, :class_name => "DocumentAlias", :foreign_key => 'alias_for', :dependent => :destroy

  scope :open_invoices, :conditions => { :kind => 'rechnung', :state => Elph[:inv_states] - %w(paid) },
                  :include => :address, :order => 'date asc, id asc'
  #scope :own_documents, :conditions => { :is_foreign => false },
  #                :include => :address, :order => 'date desc, id asc'
  scope :own_documents, where("not(is_foreign is true AND type='Email')").includes(:address).order('date desc, id asc')
  # :include => {:address => :customer}
  scope :non_aliases, where('documents.type != ?','DocumentAlias')
  scope :attachables, where(:type => [:Paper, :ExternalPaper])
  validates_presence_of :address_id, :type, :date
  validates_inclusion_of :state, :in => Elph[:inv_states] + ['',nil]

  def set_user_info user_id
    logger.info 'remove me!!!!! and reinstall :touch => true for associated models!'
  end

  def set_user_id
    self.user_id = current_user
  end

  def invoice_number_formatted
    return nil unless Elph[:inv_kinds].include? self.kind
    #logger.info "jau, immer noch #{self.date.strftime('%y%m%d')} #{self.invoice_number.to_s}"
    "#{self.date.year.to_s}-#{self.invoice_number.to_s}"
  end

  def kind
    self.read_attribute( :kind ) || self.class.name.downcase
  end

  def message_with_breaks
    message.gsub( "\n", '<br>').html_safe
  end

  def doc_name
    self.class.model_name == 'Paper' \
      ? "#{self.kind.titlecase} #{self.invoice_number_formatted || self.id}" \
      : "#{self.class.model_name.human} #{self.id}"
  end

  def main_type
    self.class.name || 'something went wrong' # should never be nil
  end

  def controller_name
    main_type.pluralize.underscore
  end

  def get_signer
    self.signer || self.user
  end

  def signing
    get_signer.signing
  end

  def linkeds
    self.linkees + self.linkers
  end
  def linkeds_plus # adds self to the list of linkeds and sorts all by date descending
    linkeds = self.linkees + self.linkers
    return linkeds unless linkeds.length > 1
    linkeds << self
    linkeds.sort {|a,b| b.date <=> a.date }
  end
  def linked_ids
    self.linkee_ids + self.linker_ids
  end
  def document_updated # for use through associated models
    self.update_attributes :last_modified_by => current_user, :updated_at => Time.now
  end
  # String#truncate sucks, so:
  def message_abbr len=50
    unless self.message.blank?
      text = self.message.sub(/\n.*/m, '')
      text.length > len ? ERB::Util.html_escape(text[0,len-3].strip) + '&hellip;'.html_safe : text
    else
      ''
    end
  end
  def subject_abbr len=35
    self.subject.blank? ? '' : ( self.subject.length > len ? ERB::Util.html_escape(self.subject[0,len-3].strip) + '&hellip;'.html_safe : self.subject )
  end
  def message_html
    self.message.gsub(/\n/,'<br />').gsub(%r|https?://[-\w]+(?:\.[-\w]+)+/?[-%=&?!.\w_/]*|,"<a href=\"\\0\">\\0</a>").html_safe unless self.message.nil?
  end
  def too_big?
    self.message && self.message.size > 500
  end
  def scalable?
    self.class == Paper && not(self.filed)
  end
  def markdown?
    self.markup == 'markdown'
  end
  def info
    infos = [ contactable.cname ]
    infos << subject_abbr unless subject.blank?
    infos.join ' - '
  end
  def message_formatted
    if self.markdown? then
      # BlueCloth.new(self.message).to_html.html_safe
      self.message.html_safe
   else
      self.message_html.html_safe
    end
  end
end
