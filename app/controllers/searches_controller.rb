class SearchesController < ApplicationController
  include CustomersPagination

  def index
    @search = Search.new(params)
    @search.customers = @search.customers.page(params[:page]).per(_customers_per_page) if @search.customers

    respond_to do |format|
      format.jsonrs # index.jsonrs.jrs
      format.html # index.html.erb
      format.xml  { render :xml => @searches }
    end
  end

  def new
    @search = Search.new

    respond_to do |format|
      format.jsonrs
      format.html # new.html.erb
      format.xml  { render :xml => @search }
    end
  end

  # POST /searches
  def create
    @search = Search.new(params)
    @search.customers = @search.customers.page(params[:page]).per(_customers_per_page)

    respond_to do |format|
      format.jsonrs { render :action => "index" }
      format.html { render :action => "index" }
      format.xml  { render :xml => @searches}
    end
  end
end
