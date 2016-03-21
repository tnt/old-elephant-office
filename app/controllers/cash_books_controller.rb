# coding: utf-8
class CashBooksController < ApplicationController
  include CashBooksHelper
  #prawnto :prawn => PdfSettings::DOC_DEFAULTS, :inline => false 
  # GET /cash_books
  # GET /cash_books.xml
  respond_to :html, :js, :pdf, :json, :jsonrs

  def index
    @cash_books = CashBook.all :include => { :paper => :address }, :order => 'date asc, id asc'
    compute_balances @cash_books
    @results = compute_cash_book
    @new_cash_book = CashBook.new
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cash_books }
      format.pdf { send_data make_pdf2(),  
        :type => 'application/pdf', :disposition => 'inline' }
    end
  end

  # GET /cash_books/1
  # GET /cash_books/1.xml
  def show
    @cash_book = CashBook.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cash_book }
    end
  end

  # GET /cash_books/new
  # GET /cash_books/new.xml
  def new
    @cash_book = CashBook.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cash_book }
    end
  end

  # GET /cash_books/1/edit
  def edit
    @cash_book = CashBook.find(params[:id])
  end

  # POST /cash_books
  # POST /cash_books.xml
  def create
    @cash_book = CashBook.new(params[:cash_book])

    respond_to do |format|
      if @cash_book.save
        flash[:notice] = 'CashBook was successfully created.'
        format.html { redirect_to(@cash_book) }
        format.xml  { render :xml => @cash_book, :status => :created, :location => @cash_book }
        format.json
        format.jsonrs
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cash_book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cash_books/1
  # PUT /cash_books/1.xml
  def update
    @cash_book = CashBook.find(params[:id])

    respond_to do |format|
      if @cash_book.update_attributes(params[:cash_book])
        flash[:notice] = 'CashBook was successfully updated.'
        format.html { redirect_to(cash_books_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash_book.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_books/1
  # DELETE /cash_books/1.xml
  def destroy
    @cash_book = CashBook.find(params[:id])
    @cash_book.destroy

    respond_to do |format|
      format.html { redirect_to(cash_books_url) }
      format.xml  { head :ok }
    end
  end
  
  ##############################################################################
  
  def clear # 
    months_back = params[:months_back].to_i || 1
    
    month, year = (c_month, c_year = Time.now.to_a[4,2])
    (1..months_back).each do 
      month -= 1
      if month == 0
        month = 12
        year -= 1
      end
    end
    first_of_following = Time.local(month==12?year+1:year, month==12?1:month+1, 1, 0, 0)
    # month = (((months_back / 12 + 1) * 12 + c_month ) - months_back - 1 ) % 12 + 1
    # year = c_year - ((months_back>c_month ? months_back-c_month : 1) / 12) - (c_month-months_back <= 0 ? 1 : 0)
    fire_log "abzurechnender Monat: #{month}/#{year} - erster des nächsten: #{first_of_following.strftime('%d.%m.%Y')}"
    #redirect_to(cash_books_url) and return
    sums = {'sale'=> nil, 'workshop'=> nil}

    #sql_conditions = "(MONTH(date)<=#{month} AND YEAR(date)<=#{year}) OR YEAR(date)<#{year}"
    
    CashBook.transaction do 
      sums.each do |k,v|
        sums[k] = CashBook.till_month(month,year).send(k).in.sum(:amount) - CashBook.till_month(month,year).send(k).out.sum(:amount)
      end
      CashBook.till_month(month,year).delete_all #sql_conditions # deletes before 0:00 UTC which is 22:00 of the day (and such the month) before in CEST
      Rails.taciturn_logger.info "   -- SUMS: #{sums}"
      sums.each do |k,v|
        #sum = v.to_s.tr ',.','.,' #  this turns negative values into positive ones
        CashBook.create( { :date => first_of_following, :amount => v.abs, :purpose => 'Abschluß Vormonat', 
                          :workshop => (k=='workshop'), :direction => ( v >= 0 ? 'in' : 'out' ) } )
      end
    end
  	
    fire_log "sale: #{sums['sale']} workshop: #{sums['workshop']}"
    respond_to do |format|
      format.html { redirect_to(cash_books_url) }
      format.xml  { head :ok }
    end
  end

  def clear_all # old version of clear
    month, year = Time.now.to_a[4,2]
    first_of_month = Time.local(year, month, 1, 0, 0)
    sums = {'sale'=> nil, 'workshop'=> nil}

    CashBook.transaction do 
      sums.each do |k,v|
        sums[k] = BigDecimal.new(CashBook.send("#{k}_in_old").sum(:amount)) - BigDecimal.new(CashBook.send("#{k}_out_old").sum(:amount))
      end
      #CashBook.delete_all "MONTH(date)<#{month} OR YEAR(date)<#{year}" # deletes before 0:00 UTC which is 22:00 of the day (and such the month) before in CEST
      CashBook.delete_all "date_part('month',date)<#{month} OR date_part('year',date)<#{year}" # deletes before 0:00 UTC which is 22:00 of the day (and such the month) before in CEST
      sums.each do |k,v|
        sum = v.to_s.tr ',.','.,'
        CashBook.create( { :date => first_of_month, :amount => sum, :purpose => 'Abschluß Vormonat', 
                          :workshop => (k=='workshop'), :direction => 'in' } )
      end
    end
  	
    respond_to do |format|
      format.html { redirect_to(cash_books_url) }
      format.xml  { head :ok }
    end
  end

  def create_ajax
    @cash_book = CashBook.new(params[:cash_book])
    
    if @cash_book.save
      @cash_books = CashBook.find :all, :conditions => "workshop=#{@cash_book.workshop}", :order => 'date asc, id asc'
      @cash_book = @cash_books.find {|cb| cb.id == @cash_book.id}
      compute_balances @cash_books
      fire_log "@cash_book.balance: #{@cash_book.balance}"
      @cash_books = @cash_books.select {|cb| cb.date > @cash_book.date} # the id of the new cash_book is naturally 
            # always > all previous and with that > all with same datetime, so the next item's date must be > the new one's
            # if there is one!!!
      fire_log "@cash_books.size: #{@cash_books.size}"
      @results = compute_cash_book
      @exceeds = @results[:total_sale] < 0 || @results[:total_workshop] < 0 || @cash_book.balance < 0
      #fire_log "@total_sale: #{@total_sale} - @total_workshop: #{@total_workshop} #{@total_sale<0} #{@total_workshop<0}" 
      #render :template => 'cash_books/new', :locals => { :cash_book => @cash_book }
      #render :template => 'cash_books/new', :locals => { :cash_book => @cash_book, :cash_books => @cash_books,
                                          #	:exceeds => @exceeds, :results => @results }
      respond_with :new_fuck_param_for_glorious_shit_hole_suckers
    else
      #render :template => 'cash_books/new', :locals => { :cash_book => @cash_book }
      render :template => 'common/alert', :locals => { :message => 'Kagge!' }
    end
  end
  
protected

  def compute_balances cash_books
  	balances = {'sale'=> BigDecimal.new('0'), 'workshop'=> BigDecimal.new('0')}
  	cash_books.each do |cb|
  		which = cb.workshop ? 'workshop' : 'sale'
  		balances[which] += cb.amount * (cb.direction=='in' ? 1 : -1)
  		cb.balance = balances[which]
  	end
  end

  def compute_cash_book # DRY like dust
  	r = {}
  	%w(sale workshop).each do |n| 
  		%w(in out).each do |m|
  			comb = "#{n}_#{m}".to_sym
  			r[comb] = CashBook.send(m).send(n).sum :amount
  		end
  	end
  	r[:total_sale] = r[:sale_in] - r[:sale_out]
  	r[:total_workshop] = r[:workshop_in] - r[:workshop_out]
  	r[:total] = r[:sale_in] + r[:workshop_in] - r[:sale_out] - r[:workshop_out]
  	return r
  end
  
  def compute_cash_book_wet # not really DRY but more readable
  	sale_in = BigDecimal.new( CashBook.sale_in.sum(:amount) )
  	sale_out = BigDecimal.new( CashBook.sale_out.sum(:amount) )
  	workshop_in = BigDecimal.new( CashBook.workshop_in.sum(:amount) )
  	workshop_out = BigDecimal.new( CashBook.workshop_out.sum(:amount) )
  	total = sale_in + workshop_in - sale_out - workshop_out
  	total_sale = sale_in - sale_out
  	total_workshop = workshop_in - workshop_out
  	return [ total, total_sale, total_workshop ]
  end
end
