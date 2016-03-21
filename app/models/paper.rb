# coding: utf-8
class Paper < Document
  include ToPdf
  include UserInfo
  include ApplicationHelper
  attr_accessible :realization_from, :realization_to, :address_id, :date, :kind, :subject, :remark, :value, :filed
  belongs_to :address, :foreign_key => :address_id
  has_many :contents, :dependent => :destroy, :order => 'position'
  validates_inclusion_of :kind, :in => Elph[:doc_kinds]
  has_one :cash_book, :dependent => :destroy
  # delegate :workshop, :workshop=, :to => :cash_book # just a test
  has_many :email_attachments, :include => {:email => :address}

  scope :invoices, where(:kind => Elph[:inv_kinds]).order('date asc, invoice_number asc')
  scope :unfiled, where(:filed => false, :system => false).order('date asc')
  delegate :rblocks, :to => :contents
  delegate :content_from_template_for_dun, :content_from_template, :invoice_from_estimate, :to => :template
  delegate :update_cash_book, :update_value, :set_invoice_number, :last_invoice_of_year, :to => :invoice_stuff

  after_initialize do
    if new_record? && our_sign.blank? && our_contact.blank?
      u = User.find current_user
      #%w(our_sign our_contact).each {|prop| self.send("#{prop}=",u.send(prop))} # the cryptic way...
      self.our_sign, self.our_contact = u.our_sign, u.our_contact
    end
  end

  before_create do
    set_invoice_number
    self.cash_book = CashBook.new(:date => self.date,
        :tax_rate => self.tax_rate, :amount => 0) if self.kind == 'barrechnung'
  end

  before_update do
    self.value = self.rblocks.first ? self.rblocks.first.total(self.tax_rate) : 0.0 # must pass the (possibly changed) tax_rate explicitly, because it is possibly not up to date
    cash_book.update_attributes({:tax_rate => self.tax_rate,
                  :date => self.date, :amount => self.value }) if cash_book
  end

  def file
    File.open self.pdf_local_path, 'wb' do |fh|
      fh.write self.to_pdf
    end
    self.update_attribute :filed, true
  end

  def unfile
    self.update_attribute :filed, false
  end

  def pdf_url
    self.filed ? URI.encode("/filed_papers/#{self.pdf_name}") : "/papers/#{self.id}.pdf"
  end

  def file_url # provisorium
    pdf_url
  end

  def foile_name # provisorium
    pdf_name
  end

  def to_blob # same same
    filed ? File.read(pdf_local_path) : self.to_pdf(:chop => Elph[:mail_papers_with_chop])
  end

  def pdf_name
   "#{self.kind.titlecase} #{'%05d' % self.id}.pdf"
  end

  def pdf_local_path
    "#{Rails.root.to_s}/public/filed_papers/#{self.pdf_name}"
  end

  def rft_both?
    return false if realization_from.nil?
    realization_from < realization_to
  end

  def template
    @template ||= PaperTemplate.new self
  end

  def invoice_stuff
    @invoice_stuff ||= InvoiceStuff.new self
  end

  def dun_times?
    Elph[:inv_states].index(self.state)
  end

  def value_formatted
    number_to_currency value
  end

  #validates_with_block do
  #	self.realization_from > self.realization_to ? true : [ false,  '\'vom\' darf nicht größer als \'bis\' sein' ]
  #end

  def based_ons
    Paper.find :all, :conditions => "based_on=#{self.id}"
  end
end
