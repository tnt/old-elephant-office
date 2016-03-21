# coding: utf-8
class EmailTestsController < ApplicationController
  respond_to :html, :json, :jsonrs, :pdf
  
  include MyMimes

  def index
    @new_emails = EmailChecker.check_mails :since => 7500, :re_read_all => true
    render :html => '<a href="#">neu laden</a>'
  end

  def show
    flash[:notice] = "EmailChecker.test_it: '#{EmailChecker.test_it}'"
    #EmailChecker.reset_uids_of_outgone_emails
  end
 
  def jason
    fire_log 'Hey man!'
    fire_log 'Hey Woman!'
    logger.info headers.inspect() +  response.headers.inspect()
    respond_to do |format|
      format.html
      format.xml  { render :xml => @customers }
      format.jsonrs
      format.json
    end
  end
  
  protected
  

end
