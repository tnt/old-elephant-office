# coding: utf-8
class CustomersController < ApplicationController
  include CustomersPagination
  before_filter :set_last_customers
  # GET /customers
  # GET /customers.xml
  def index
    @customers = Customer.non_system
    @customers = @customers.search(params[:search_simp],params[:phonetic]) unless params[:search_simp].blank?
    #@customer = (session[:current_customer] ? Customer.find(session[:current_customer]) :  @customers[0])
    @customer = Customer.find_by_id(session[:current_customer]) if  session[:current_customer]
    page = params[:page]
    page ||= Customer.items_page(@customer,_customers_per_page.to_i) if params[:search_simp].blank? && @customer
    tct_logger.info "page: '#{page}'"
    @customers = @customers.page(page).per(_customers_per_page)
    fire_log @customers.length
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
      format.json { render :json => { :customers => @customers.map {|c| {id: c.id, name: c.name}}, :count => Customer.count } }
      format.jsonrs
      format.yaml { render :yaml => @customers }
    end
  end
  
  def diacritics_limit
    diacritics = {'a' => 'aÄÂÅÁÀÅäâåáàå', 'e' => 'eËÊÉÈëêéè', 'i' => 'iÌÍÏÎìíïî', 'o' => 'oöóòôøÖÓÒÔØ', 'u' => 'uüúùûÜÚÙÛ' }
    diacritics.keys.include?(session[:limit_to_char]) ? "[#{diacritics[session[:limit_to_char]]}]" : session[:limit_to_char] 
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    tct_logger.info " Klasse: #{DocumentAlias.class.name}"
    @customer = Customer.find(params[:id], {:include => {:contactables => :documents}})
    tct_logger.info "document_ids: #{@customer.document_ids} Klasse: #{DocumentAlias.class.name}"
    #fire_options :mask_ruby_types => false
    session[:current_customer] = @customer.id

    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.xml  { render :xml => @customer }
      format.json { render :json => {id: @customer.id, addresses: @customer.current_addresses.map {|a| {id: a.id, address: a.to_string} } } }
      format.jsonrs
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new
    #@customer.addresses.build.build_specific

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])
    prepare_existing_contactable
    
    respond_to do |format|
      if @customer.save
        assign_existing_contactable
        flash[:notice] = 'Customer was successfully created.'
        format.html { redirect_to(@customer) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def prepare_existing_contactable
    @existing_contactable = Contactable.find params[:existing_contactable_id] if params[:existing_contactable_id]
  end
  
  def assign_existing_contactable
    @customer.send(@existing_contactable.type.underscore.pluralize) << @existing_contactable  if params[:existing_contactable_id]
  end
  
  def _set_session_vars
    customers_initial = @customer.name[0,1].downcase
    session[:limit_to_char] = customers_initial
    session[:last_customers] ||= {}
    session[:last_customers][customers_initial] = @customer.id
    session[:last_pages][session[:limit_to_char]] = \
      Customer.items_before(diacritics_limit, @customer.name).size.to_i / cookies[:customers_per_page].to_i + 1
  end
  
  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer], :without_protection => false)
        flash[:notice] = 'Customer was successfully updated.'
        #format.html { redirect_to(@customer) }
        format.html { redirect_to(customers_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end
  
  ##########################################
  
  def search # currently not in use
    @customers = Customer.search(params[:search])
    @customer = session[:last_customers] && session[:last_customers][session[:limit_to_char]] ? 
                              Customer.find(session[:last_customers][session[:limit_to_char]]) : 
                              @customers[0]
  end
  
  def ajax_show
    @customer = Customer.find(params[:id], {:include => {:contactables => :documents }})
    session[:last_customers] ||= {}
    session[:current_customer] = session[:last_customers][session[:limit_to_char]] = @customer.id
    render :partial => 'customers/show', :locals => { :customer => @customer }
  end
  
  def add_document
    customer = Customer.find(params[:id])
    if customer.addresses.length > 0
      address = customer.invoice_address
      logger.info "address.id: '#{address.id}'"
      @document = Document.new(:address_id => address.id, :user_id => session[:user], :last_modified_by => session[:user])
      render :template => 'papers/new'
    else
      flash[:notice] = 'Bitte zuerst eine Adresse anlegen.'
      @address = Address.new :customer_id => customer.id
      render :template => 'addresses/new'
    end
  end
  
  def choice_reassign_address
    @customer_id = params[:id]
    respond_to do |format|
      format.jsonrs
    end
  end
  
  def confirm_reassign_address
    @customer_id = params[:id]
    unless @contactable = Contactable.where(:id => params[:address_id]).first 
      @message = "Address with ID '#{params[:address_id]}' does not exist."
      render 'customers/choice_reassign_address', 
            :locals => { :message => "Address with ID '#{params[:address_id]}' does not exist. ", 
            :customer_id => params[:id] }
      return
    end
      
    respond_to do |format|
      format.jsonrs
    end
  end
  
  def reassign_address
    @contactable = Contactable.find params[:address_id]
    other_customer = @contactable.customer
    address_count_of_other = other_customer.contactables.count if other_customer
    attrs = { :customer_id => params[:id], :outdated => false }
    attrs.merge({ :invoice_address => false, :delivery_address => false }) if @contactable.type.to_s == 'Address' 
    if @contactable.update_attributes attrs
      Customer.find(other_customer.id).destroy if address_count_of_other == 1 # preventing the contactable to get deleted
    end
    render :template => 'customers/reassign_address', :locals => { :customer_id => params[:id] }
  end
  
  def add_alias_form
    @customer = params[:id] ? Customer.find(params[:id]) : Customer.new
    @alias = @customer.aliases.build
  end
  
  def add_contactable_form
    @customer = params[:id] ? Customer.find(params[:id]) : Customer.new
    @contactable = @customer.send(params[:type].underscore.pluralize).build if \
      %w(Address EmailAddress PhoneNumber Person).include? params[:type]
    @contactable.build_specific
  end
  
  def select_reassign_existing_contactable
    @customers = Customer.order(:name).page(params[:page]).per(20); @customer = Customer.new
    @existing_contactable = Contactable.find params[:existing_contactable_id]
    respond_to do |format|
      format.html
      format.xml  { render :xml => @customers }
      format.jsonrs
    end
  end

  def assign_existing_contactable_to_existing_customer
    @customer = Customer.find(params[:id])
    @existing_contactable = Contactable.find params[:existing_contactable_id]
    @customer.contactables << @existing_contactable
    flash[:notice] = 'Adresse wurde zugewiesen.'
    respond_to do |format|
      format.html # redirect_to(customers_url)
      format.xml  { render :xml => @customers }
      format.jsonrs
    end
  end

  def assign_existing_contactable_to_new_customer
    @customer = Customer.new
    @existing_contactable = Contactable.find params[:existing_contactable_id]
    @customer.name = @existing_contactable.full_name
    render :template => 'customers/new'
  end
  def rstest
    @customer = Customer.find 1200
    #render :template => 'customers/test_rjs'
  end
  protected
  def set_last_customers
    tct_logger.info "params[:id] = #{params[:id]}"
    @_da_cookie_hash ||= {:expires => Time.now+60*60*24*30} 
    cookies[:last_customers] = @_da_cookie_hash.merge(:value => '') unless cookies[:last_customers]
    cookies[:last_customers] =  @_da_cookie_hash.merge(:value => cookies[:last_customers].split(',').unshift(params[:id]).uniq[0,10].join(',')) if params[:id] && cookies[:last_customers] 
    # reading a cookie always gives the value of the previous request regardless of what has been written to it in the current request
  end
end




