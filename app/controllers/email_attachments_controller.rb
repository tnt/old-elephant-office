# coding: utf-8
class EmailAttachmentsController < ApplicationController

  def document_choice
    @papers = Contactable.find(params[:address_id]).customer.attachables
    render :template => 'email_attachments/document_choice', :locals => {:email_id => params[:email_id]}
  end
  
  def new_document
    #email = (params[:email_id] == 'NEW_RECORD') ? Email.new(:address_id => params[:address_id]) : Email.find(params[:email_id])
    @email = Email.new(:address_id => params[:address_id])
    fire_log @email.address_id, 'address_id'
    #@attachment = EmailAttachment.new :email_id => params[:email_id], :kind => 'document' #, :paper_id => params[:paper_id]
    @attachment = EmailAttachment.new :kind => 'document' #, :paper_id => params[:paper_id]
    fire_info @attachment.kind, 'attachmanet.kind'
    @attachment.document = Document.find params[:document_id]
    #render :template => 'email_attachments/new_paper', :locals => { :email => email }
  rescue Exception => exc
    if exc.class == ActiveRecord::RecordNotFound
      render :template => 'common/alert', :locals => {:message => "Ein Dokument mit der Nummer #{params[:paper_id]} existiert nicht!"}
    else
      render :template => 'common/alert', :locals => {:message => "Fehler '#{exc.class.to_s}':\n\n'#{exc.message}'\n\n#{exc.backtrace.join '\n'}"}
    end
  end

  def new_file
    render :template => 'email_attachments/file_form'
  end
end
