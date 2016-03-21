# coding: utf-8

class DocumentsController < ApplicationController

  include ActionView::Helpers::NumberHelper # for eval in content_from_template

  #prawnto :prawn => {:page_size => 'A4', :left_margin => 56.69, :right_margin => 56.69, 
  #			:top_margin => 31 , :bottom_margin => 50 }, :inline => false 

  def test_action
    
    render :text => "controller_name: '#{controller_name}'"
  end
  # GET /documents
  # GET /documents.xml
  def index
    page = session[:last_documents_page] = params[:page] || session[:last_documents_page] || '1'
    @documents_per_page = params[:documents_per_page] || cookies[:documents_per_page] || Elph[:items_per_page].to_s
    cookies[:documents_per_page] = { :value => @documents_per_page, :expires => 1.year.from_now }
    @documents = Document.own_documents.non_aliases.page(page).per(@documents_per_page).order('date desc, id desc')
    
    #fire_log self.public_methods.sort, 'publ_m'
    fire_log controller_name, 'controller_name'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    #prawnto :inline => false
    @document = Document.find(params[:id])
    set_unseen_emails_count @document unless @document.seen
    #fire_log session.session_id
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
#			format.pdf { send_data render_pdf( @document ),  
#				:type => 'application/pdf', :disposition => 'inline' }
      format.pdf
    end
  end

  # GET /documents/new
  # GET /documents/new.xml
  def new
    #@document = Document.new(params[:type] ? {:type => params[:type]} : {})
    #@document = doc.becomes params[:type].classify.constantize if %w(Paper Email PhoneCall Visit).include? params[:type] 
    @document = params[:type].constantize.new if %w(Paper Email PhoneCall Visit).include? params[:type] 
    #@document.set_user_info session[:user]
    @document.date = DateTime.now

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
    @users = User.find(:all)
    set_unseen_emails_count @document unless @document.seen
  end

  # POST /documents
  # POST /documents.xml
  def create
    @document = params[:type].constantize.new(params[params[:type].underscore.to_sym], :without_protection => false)\
      if %w(Paper Email PhoneCall Visit ExternalPaper).include? params[:type] 
    @document.set_user_info session[:user]
    #tct_logger.info "@document.inspect: #{@document.inspect}\n params.inspect: #{params.inspect}"
    @document.send_now = true if params[:send_now] # only for emails
    #@document.files.first.file = params[:file] if params[:type] == 'Email'

    respond_to do |format|
      if @document.save
        logger.info " --- #{params.inspect}" if @document.type == 'Email'
        logger.info " --- #{@document.inspect}" if @document.type == 'Email'
        flash[:notice] = "#{@document.type} wurde gespeichert."
        flash[@document.sent ? :notice : :warning] = "Email wurde #{@document.sent ? '' : 'NICHT'} versendet." if @document.type == 'Email'
        format.html { redirect_to(customers_url) }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        tct_logger.info "!!! Could not be saved! --- #{params.inspect}"
        tct_logger.info " --- #{@document.inspect}"
        format.html { render :action => "new", :controller => "#{@document.main_type.downcase}s" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    @document = Document.find(params[:id])
    @document.send_now = true if params[:send_now] # only for emails
    
    logger.info "\t\t PARAMS: #{params.inspect}"
    respond_to do |format|
      if @document.update_attributes(params[@document.type.underscore.to_sym], :without_protection => false)
        logger.info " PARAMS #{params[@document.type.underscore.to_sym]}"
        flash[:notice] = "#{@document.type} wurde gespeichert."
        #flash[:notice] = "Email wurde #{@document.sent ? '' : 'NICHT'} versendet." if ( @document.type == 'Email' && params[:send_now] )
        flash[@document.sent ? :notice : :warning] = "Email wurde #{@document.sent ? '' : 'NICHT'} versendet." if ( @document.type == 'Email' && params[:send_now] )
        format.html { redirect_to(customers_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document = Document.find(params[:id])
    #@document.destroy
    #@paper.destroy
    flash[:notice] = 'Geht nicht, weil nicht gut...'

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end
  
  def preview
    @document = Document.find(params[:id])
    render :partial => "#{@document.main_type.underscore.pluralize}/preview", :locals => {:document => @document}
  end

  def destroy_ajax_document
    @document = Document.find(params[:id])
    @document.destroy

    #render :partial => 'common/deleted', :locals => { :model => 'document' }
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
      format.jsonrs
      format.json
    end
  end
  
  def change_scale
    @document = Document.find(params[:id])
    @document.update_attributes(params[:document])
    render :nothing => true
  end
  
  def ajax_choice_linked # provides the choice to choose a (before this of course not) linked
    @document = Document.find(params[:id])
    #@documents = @document.customer.documents # defined in models/customer.rb
    @documents = @document.customer.non_aliases# - @document.linkeds # defined in models/customer.rb
    @documents.reject! {|doc| @document.linkeds.include? doc or doc == @document }
    #render :template => 'documents/choice_linkeds'
  end
  
  def ajax_create_linked
    @document = Document.find(params[:id])
    linkee = Document.find(params[:linkee_id])
    @document.linkees << linkee unless ( @document == linkee || linkee.type == 'DocumentAlias' )
    #render :template => 'documents/update_linkeds'
  rescue ActiveRecord::RecordNotFound => exc
    render :template => 'common/alert', :locals => {:message => "Ein Dokument mit der Nummer '#{params[:linkee_id]}' existiert nicht!"}
  rescue Exception => exc
    render :template => 'common/alert', :locals => {:message => "Mist! \n\n#{exc.inspect}"}
  end

  def ajax_destroy_linked
    document = Document.find(params[:id])
    @linked =  Document.find(params[:linked_id])
    document.linkees.delete(@linked) # delete function doesn't return a meaningful value
    @linked.linkees.delete(document) # so we have to call it on both docs	prophylactically
#    respond_to do |format|
#      format.json
#    end
  end
  
  def address_choice
    @document = Document.find(params[:id])
    contactable =  @document.contactable
    contactables = contactable.customer.send("current_#{contactable.type.to_s.underscore.pluralize}")	#.reject {|addr| addr == address}
    render :template => 'contactables/contactable_choice', :locals => { :contactables => contactables, :document => @document }
  end
  
  def select_address
    @document = Document.find(params[:id])
    @document.update_attribute :address_id, params[:contactable_id]
    show_address_chooser = @document.contactable.customer.addresses.length > 1
    #render :partial => 'addresses/address_chooser', :object => @document, :locals => { :show_address_chooser => show_address_chooser }
    render :template => 'contactables/select_address', :locals => { :document => @document,
      :contactable => @document.contactable, :show_contactable_chooser => true }
  end

  def send_by_email
    document = Document.find(params[:id])

    #@document = Email.new :address_id => document.customer.current_email_addresses[0].id, :subject => document.doc_name
    @document = Email.new :address_id => document.customer.current_email_addresses.first.id, :subject => document.doc_name
    @document.attachments << EmailAttachment.new( { :kind => 'document', :document_id => document.id } )
    @document.set_user_info session[:user]
    
    render :template => 'emails/new'
  end

end


