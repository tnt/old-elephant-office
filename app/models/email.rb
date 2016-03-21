# coding: utf-8

class Email < Document
  belongs_to :email_address, :foreign_key => :address_id
  delegate :customer, :to => :email_address
  alias contactable email_address
  has_many :attachments, :class_name => 'EmailAttachment', :dependent => :destroy
  # :is_foreign false == 'our mail to customer', true == 'is mail from customer'
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  validates_presence_of :date, :address_id
  default_scope :order => 'date desc'
  scope :our_emails, where(:is_foreign => false)
  scope :unsent_emails, our_emails.where(:sent => false)
  scope :outgone_emails, our_emails.where(:sent => true)
  scope :foreign_emails, where(:is_foreign => true)
  scope :unseen_emails, foreign_emails.where(:seen => false)
  #scope :inbox, :conditions => { :imap_folder => 'inbox' }
  #scope :sent, :conditions => { :imap_folder => 'sent' }


  attr_accessor :send_now, :has_text_plain_part
  attr_accessible :sent, :is_foreign, :subject, :date, :message, :attachments_attributes

  delegate :email_address_complete, :to => :email_address
  delegate :files, :to => :attachments

  imap_settings = Elph[:imap_settings]

  after_initialize {self.message = User.find(current_user).signature if self.new_record? && self.message.nil?}
  before_validation {self.date = Time.now if editable?}

  after_save do
    if send_now
      begin
        tmail = EmailMailer.email(self)
        Rails.taciturn_logger.info " ---------------- probiere IMAP-Verbindung aufzubauen ---------------"
        Rails.taciturn_logger.info imap_settings
        imap = Net::IMAP.new(imap_settings[:host], {:ssl => {:verify_mode => OpenSSL::SSL::VERIFY_NONE}})
        # imap.starttls({}, verify=false)
        imap.login(imap_settings[:user_name], imap_settings[:password])
        # imap.authenticate('LOGIN', imap_settings[:user_name], imap_settings[:password])
        Rails.taciturn_logger.info " ------- IMAP-Verbindung scheint zu stehen, probiere Nachricht zu speichern ----"
        resp = imap.append(imap_settings[:folders][:sent], tmail.to_s, [:Seen])
        imap.select(imap_settings[:folders][:sent])
        uid = imap.uid_search(['HEADER','Message-Id',tmail.message_id])[0]
        ActiveRecord::Base.connection.execute "UPDATE documents SET imap_uid=#{uid},imap_server=#{imap_settings[:imap_server]},self_generated_email=true WHERE id=#{self.id};"

        Rails.taciturn_logger.info " ---------------- try to send... ---------------- id: #{id} --- "
        tmail.deliver
        # Rails.taciturn_logger.info " ---------------- ---------------- id: #{id}  tmail.inspect: #{tmail.inspect}--- "
        time_offset = {'CET' => 1, 'CEST' => 2}[Time.now.to_a[9]]
        self.sent = true # is not persistent (but needed), so:
        ActiveRecord::Base.connection.execute "UPDATE documents SET sent=true,date=now(),message_id='<#{tmail.message_id}>' WHERE id=#{self.id};"
        Rails.taciturn_logger.info "    et scheint zu scheinen dat et scheinen tut ... "
      # rescue Net::IMAP::NoResponseError => exc
      #   Rails.taciturn_logger.info " ---------------- IMAP-Fehler: \n  #{exc.inspect}"
      # rescue Exception => exc
      #   Rails.taciturn_logger.info " ---------------- IMAP-Fehler: \n  #{exc.inspect} #{exc.backtrace.inspect}"
      rescue Exception => exc
        failed_to_send exc
        imap.uid_store(uid, "+FLAGS.SILENT", [:Deleted]) unless uid.nil?
        imap.expunge() unless uid.nil?
      ensure
        imap.disconnect
      end
    end
  end

  def failed_to_send exc
      Rails.taciturn_logger.info "Fehler: \n  #{exc.inspect} #{exc.backtrace.inspect}"
      self.sent = false # überflüssig aber ...
      ActiveRecord::Base.connection.execute "UPDATE documents SET sent=false WHERE id=#{self.id};"
  end

  def editable?
    ! (sent || is_foreign)
  end
end
