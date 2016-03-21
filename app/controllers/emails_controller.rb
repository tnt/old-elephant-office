# coding: utf-8
class EmailsController < DocumentsController
  
  def index
    @emails = Email.foreign_emails
  end
  
  def seen
    Email.find(params[:id]).update_attribute :seen, true
    render :nothing => true
  end
  
  def unseen_emails
    @unseen_emails = Email.unseen_emails
  end
  
end
