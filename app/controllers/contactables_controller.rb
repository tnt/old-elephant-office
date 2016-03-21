# coding: utf-8
class ContactablesController < ApplicationController
  # GET /contactables
  # GET /contactables.xml
  ADDRESSES_PER_PAGE = 20
  def index
    session[:limit_to_char] = params[:limit_to_char] || session[:limit_to_char] || 'all'
    session[:page] = params[:page] || session[:page] || '0'
    @contactables_per_page = params[:addresses_per_page] || cookies[:addresses_per_page] || ADDRESSES_PER_PAGE.to_s
    cookies[:addresses_per_page] = { :value => @contactables_per_page, :expires => 1.year.from_now }
    #fire_log session[:page]
    subset = {:limit => @contactables_per_page.to_i, :offset => @contactables_per_page.to_i * session[:page].to_i, :order => 'name'}
    subset[:conditions] = [ 'name like ?', "#{session[:limit_to_char]}%" ] unless session[:limit_to_char] == 'all'
    @contactables = Contactable.find(:all, subset)
    @link_to_next = @contactables.length == @contactables_per_page.to_i
    if @link_to_next
      subset[:offset] = @contactables_per_page.to_i * ( session[:page].to_i + 1  )
      @link_to_next = Contactable.find(:all, subset).length > 0
    end
    #fire_log @contactables.length
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contactables }
    end
  end

  # GET /contactables/1
  # GET /contactables/1.xml
  def show
    @contactable = Contactable.find(params[:id])
   #@documents = Document.find(:all, :conditions => { :customer_id => @contactable.id } )

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contactable }
    end
  end

  # GET /contactables/new
  # GET /contactables/new.xml
  def new
    @contactable = params[:type].constantize.new(:customer_id => params[:customer_id]) \
        if %w(Address EmailAddress PhoneNumber Person).include? params[:type] 
    @contactable.build_specific
    #fire_log @contactable.specific
    
    first_addr = @contactable.customer.addresses[0] # copying some attributes from an existing address
    @contactable.attributes = {:name => first_addr.name, :firstname => first_addr.firstname, :title => first_addr.title} \
      if (first_addr && %w(Address EmailAddress Person).include?(params[:type])) 

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contactable }
    end
  end

  # GET /contactables/1/edit
  def edit
    @contactable = Contactable.find(params[:id])
  end

  # POST /contactables
  # POST /contactable.xml
  def create
    @contactable = params[:contactable][:type].constantize.new(params[:contactable]) \
        if %w(Address EmailAddress PhoneNumber Person).include? params[:contactable][:type] 

    respond_to do |format|
      if @contactable.save
        logger.info "params[:old_address_id]: '#{params[:old_address_id]}'"
        unless params[:old_address_id].nil? or params[:old_address_id].empty?
          old_address = Contactable.find params[:old_address_id]
          update_params = { :outdated => true }
          update_params[:specific_attributes] = { :invoice_address => false, :delivery_address => false } if old_address.class.name == 'Address'
          old_address.update_attributes update_params if old_address.customer == @contactable.customer
        end
        #fire_log @contactable.inspect, '@contactable'
        @contactable.update_attributes(:invoice_address=>true,:delivery_address=>true) if ( @contactable.class.name == 'Address' && @contactable.customer.current_addresses.length == 1)
        flash[:notice] = 'Contactable was successfully created.'
        #format.html { redirect_to(@contactable.customer) }
        format.html { redirect_to(customers_url) }
        format.xml  { render :xml => @contactable, :status => :created, :location => @contactable }
      else
        @old_address_id = params[:old_address_id]
        format.html { render :action => "new" }
        format.xml  { render :xml => @contactable.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contactables/1
  # PUT /contactables/1.xml
  def update
    @contactable = Contactable.find(params[:id])

    respond_to do |format|
      if @contactable.update_attributes(params[:contactable])
        flash[:notice] = 'Address was successfully updated.'
        #format.html { redirect_to(@contactable.customer) }
        format.html { redirect_to(customers_url) }
        format.xml  { head :ok }
        format.js #{ render :template => 'addresses/update' }
        format.json
        format.jsonrs
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contactable.errors, :status => :unprocessable_entity }
        format.js { render :template => 'common/alert', :locals => { :message => 'Hat leider nich geklappt! - Vielleicht einfach nochmal probieren?' } }
        format.json { render :template => 'common/alert', :locals => { :message => 'Hat leider nich geklappt! - Vielleicht einfach nochmal probieren?' } }
        format.jsonrs { render :template => 'common/alert', :locals => { :message => 'Hat leider nich geklappt! - Vielleicht einfach nochmal probieren?' } }
      end
    end
  end

  # DELETE /contactables/1
  # DELETE /contactables/1.xml
  def destroy
    @contactable = Contactable.find(params[:id])
    @contactable.destroy

    respond_to do |format|
      format.html { redirect_to(show_customer_path(@contactable.customer)) }
      format.xml  { head :ok }
    end
  end
  
  
  def change
    old_contactable = Contactable.find(params[:id]) 
    @contactable = old_contactable.dup
    @contactable.specific = old_contactable.specific.dup
    @old_address_id = params[:id]
    render :template => 'contactables/new'
  end
  
  def add_document
    address = Contactable.find(params[:id])
    if %w(Paper Email PhoneCall Visit ExternalPaper).include? params[:type] 
      @document = params[:type].constantize.new :address_id => address.id, :user_id => session[:user],
                  :last_modified_by => session[:user], :date => DateTime.now, :realization_from => DateTime.now, 
                  :realization_to => DateTime.now
      #@document.attributes = {:address_id => address.id, :user_id => session[:user], :last_modified_by => session[:user]}
      #@document.type = params[:type] # must be set explicitly in this way!
      #fire_log "@document.type: #{@document.type}"
      #address.documents << @document
      #template = %w(PhoneCall Visit).include?(params[:type]) ? 'Talk' : params[:type]
      #fire_log "@document.is_foreign: #{@document.is_foreign}"
      @document.is_foreign = true if %w(PhoneCall Visit ExternalPaper).include? params[:type] # just setting a default value
      #fire_log "@document.is_foreign: #{@document.is_foreign}"
      #render :template => "#{template.downcase}s/new"
      render :template => "#{@document.main_type.underscore}s/new"
    end
    #render :template => "papers/new"
  end

  def add_document_old2
    address = Contactable.find(params[:id])
    if %w(Paper Email PhoneCall Visit).include? params[:type] 
      @document = eval "#{params[:type]}.new"
      @document.attributes = {:address_id => address.id, :user_id => session[:user], :last_modified_by => session[:user]}
      #fire_log "@document.main_type = '#{@document.main_type}'"
      render :template => "#{@document.main_type.downcase}s/new"
    end
    #render :template => "papers/new"
  end

  def add_document_old
    address = Contactable.find(params[:id])
    @document = eval "#{params[:type]}.new" if %w(Paper Email PhoneCall Visit).include? params[:type] 
    {:address_id => address.id, :user_id => session[:user], :last_modified_by => session[:user]}.each do |k,v|
      @document.send("#{k}=", v)
    end
    #@document.type = params[:type]
    #fire_log "@document.type = '#{@document.type}'"
    render :template => "#{@document.type.downcase}s/new"
    logger.debug "@document.type = '#{@document.type}'"
    #render :template => "papers/new"
  end

  def mark_outdated  
    @contactable = Contactable.find(params[:id])
    if params[:attribute] = 'outdated'
      attributes = @contactable.mark_outdated 
      render :template => 'addresses/set_single_attribute', :locals => { :attributes => attributes }
    else
      render :template => 'common/alert', :locals => { :message => 'Ohne sowat, bitte!' }
    end
  end
  
protected 

  def valid_subclass? type
    %w(Paper Email PhoneCall Visit).include? type
  end
end
