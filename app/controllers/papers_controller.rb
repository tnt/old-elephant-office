# coding: utf-8
            
class PapersController < DocumentsController

  include ActionView::Helpers::NumberHelper # for eval in content_from_template
  include PapersHelper


  # GET /documents
  # GET /documents.xml
  def index
    #subset = {:limit => @customers_per_page.to_i, :offset => @customers_per_page.to_i * session[:page].to_i, :order => 'name'}
    subset = {:order => 'date desc, id desc'}
    #subset[:conditions] = [ 'name like ?', "#{session[:limit_to_char]}%" ] unless session[:limit_to_char] == 'all'
    @papers = Paper.find(:all, subset)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @papers }
    end
  end

  # GET /papers/1
  # GET /papers/1.xml
  def show
    @paper = Paper.find(params[:id])
    @show_contactable_chooser = @paper.contactable.customer.addresses.length > 1
    
    respond_to do |format|
      if @paper.filed?
        format.html { redirect_to "#{@paper.file_url}", :status => 302 }
        format.pdf { redirect_to "#{@paper.file_url}", :status => 302 }
      else
        format.html # show.html.erb
        format.xml  { render :xml => @paper }
        format.pdf do
          pdf = @paper.to_pdf(:chop => params[:chop])
          Rails.taciturn_logger.info pdf.size
          send_data pdf, :type => 'application/pdf', :disposition => 'inline', :filename => @paper.doc_name
        end
      end
    end
  end

  # GET /papers/new
  # GET /papers/new.xml
  def new
    @paper = Paper.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @paper }
    end
  end

  # GET /papers/1/edit
  def edit
    @paper = Paper.find(params[:id])
    @users = User.find(:all)
  end

  # POST /papers
  # POST /papers.xml
  def create
    @paper = Paper.new(params[:paper])

    @paper.transaction do
      respond_to do |format|
        if @paper.save
          flash[:notice] = 'Document was created.'
          @paper.content_from_template
          format.html { redirect_to(@paper) }
          format.xml  { render :xml => @paper, :status => :created, :location => @paper }
        else
          @document = @paper
          format.html { render :action => "new" }
          format.xml  { render :xml => @paper.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /papers/1
  # PUT /papers/1.xml
  def update
    @paper = Paper.find(params[:id])
    
    respond_to do |format|
      if @paper.update_attributes(params[:paper])
        flash[:notice] = 'Document was successfully updated.'
        format.html { redirect_to(@paper) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @paper.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /papers/1
  # DELETE /papers/1.xml
  def destroy
    @paper = Paper.find(params[:id])
    #@paper.destroy
    flash[:notice] = 'Geht nicht, weil nicht gut...'

    respond_to do |format|
      format.html { redirect_to(papers_url) }
      format.xml  { head :ok }
    end
  end

  def file
    @paper = Paper.find(params[:id])
    @paper.file
    respond_to do |format|
      format.jsonrs
    end
  end

  def unfile
    @paper = Paper.find(params[:id])
    @paper.unfile
  end

  def send_by_email_old
    paper = Paper.find(params[:id])

    @document = Email.new :address_id => paper.customer.current_email_addresses[0].id, :subject => "#{paper.kind.titlecase} #{paper.invoice_number_formatted || paper.id}"
    @document.attachments << EmailAttachment.new( { :kind => 'paper', :paper_id => paper.id } )
    @document.set_user_info session[:user]
    
    render :template => 'emails/new'
  end

  def destroy_ajax_document

    @document = Paper.find(params[:id])

    if Elph[:inv_kinds].include? @document.kind 
      i_number = InvoiceNumber.find :first, :conditions => { :year =>  @document.date.year }
      if @document.invoice_number == i_number.number
        Paper.transaction do
          i_number.update_attribute :number, i_number.number - 1
          @document.destroy
        end
        render :template => 'documents/destroy_ajax_document'
      else
        #l_o_year = Paper.find :first, :conditions => "YEAR(date)='#{i_number.year.to_s}' AND invoice_number='#{i_number.number}'", :include => :address
        l_o_year = Paper.find :first, :conditions => "date_part('year',date)='#{i_number.year.to_s}' AND invoice_number='#{i_number.number}'", :include => :address
        part_two = l_o_year ? "\n\nDie letzte Rechnung ist die #{l_o_year.kind.titlecase} Nr. #{l_o_year.invoice_number_formatted}\n"\
                                + "    (Dok._Nr. #{l_o_year.id}) an '#{l_o_year.address.name}'." \
                            : ''
        render :template => 'common/alert', :locals => { :message => "Es kann immer nur die letzte Rechnung gelöscht werden."\
                            +	 part_two }
      end
    else
      @document.destroy
      render :template => 'documents/destroy_ajax_document'
    end
  end
  
  def change_scale
    @paper = Paper.find(params[:id])
    if @paper.update_attribute :scale, params[:value]
      render :nothing => true
    else
      render :nothing => true, :status => 404
    end
  end
  
  def open_invoices
    @papers = Paper.open_invoices
    #@total = @documents.inject(0.0) {|sum,d| sum + d.value.to_f}
    @total = @papers.sum(:value).to_f

    tct_logger.info DocumentAlias.class.to_s

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @papers }
    end
  end

  def ajax_set_state_paid
    @paper = Paper.find(params[:id])
    if @paper
      @paper.update_attribute :state, 'paid'
      @new_total = Paper.open_invoices.sum(:value)
      render :template => 'papers/set_state_paid'
    end
  end
  
  def dun_from_invoice
    @odoc = Paper.find(params[:id])
    @paper = Paper.new :kind => 'mahnung', :address_id => @odoc.address_id, :date => Time.now, :based_on => @odoc.id
    @nth_dun = @odoc.dun_times? + 1
    if @paper.save
      fire_log "@paper.id = '#{@paper.id}'"
      flash[:notice] = 'Document was created.'
      @paper.content_from_template_for_dun @odoc
      @odoc.update_attribute :state, Elph[:inv_states][@nth_dun]
      @odoc.linkees << @paper
      redirect_to(@paper)
    else
      flash[:notice] = 'kacke!'
      fire_log @paper.errors.full_messages
      render :text => @paper.errors.full_messages
      redirect_to('open_invoices')
    end 
  end

  def invoices_from_offer
    @paper = Paper.find(params[:id])
  end
  
  def invoice_from_offer
    @odoc = Paper.find(params[:id])
    if @odoc.based_ons.length > 0 && ! params[:force]
      redirect_to :action => 'invoices_from_offer', :id => @odoc.id  and return
    end
    @paper = Paper.new :kind => 'rechnung', :address_id => @odoc.address_id, :date => Time.now, :based_on => @odoc.id, :value => @odoc.value, :realization_to => Date.today, :realization_from => Date.today
    @paper.set_user_info session[:user]
    if @paper.save
      @paper.invoice_from_estimate @odoc
      @odoc.linkees << @paper
      redirect_to(@paper) and return
    else
      fire_log @paper.errors.full_messages
      render :text => @paper.errors.full_messages and return
    end
  end
  
  protected
end


