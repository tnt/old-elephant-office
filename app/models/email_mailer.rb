# coding: utf-8
class EmailMailer < ActionMailer::Base
  include PapersHelper
  include ApplicationHelper

  def email(email)
    #logger.info ' email.inspect	 ++++++++++++++ ' + email.inspect
    @email = email

    mail_hash = {}

    mail_hash[:to] = email.email_address_complete
    mail_hash[:subject]  = email.subject
    mail_hash[:from]  = "Thelonius Kort <tkort@banza.net>"
    headers['X-Mailer'] = 'Elephant 0.1'

    email.attachments.each do |att|
      next if att._destroy
      if att.kind == 'document'
        document = att.document
        body = document.to_blob
        name = document.foile_name
      elsif att.kind == 'file'
        body = File.read(att.real_path)
        name = att.file_name
      end
      #attachment :content_type => "#{att.content_type}; name=#{name}", :body => body, :content_disposition => "attachment; filename=#{name}"
      attachments[name] = {:mime_type => att.content_type, :content => body}  #, :filename => name, :content_disposition => 'attachment'
      #fire_log 'schiet!'
      # logger.info 'kagggeeeegeee_________________________!!!!!!!!!!!!'
    end

    #render :text => 	email
    mail mail_hash
  end
end
