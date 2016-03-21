# coding: utf-8
class RblockLinesController < ApplicationController
  # GET /rblock_lines
  # GET /rblock_lines.xml
  def index
    @rblock_lines = RblockLine.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rblock_lines }
    end
  end

  # GET /rblock_lines/1
  # GET /rblock_lines/1.xml
  def show
    @rblock_line = RblockLine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rblock_line }
    end
  end

  # GET /rblock_lines/new
  # GET /rblock_lines/new.xml
  def new
    @rblock_line = RblockLine.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rblock_line }
    end
  end

  # GET /rblock_lines/1/edit
  def edit
    @rblock_line = RblockLine.find(params[:id])
  end

  # POST /rblock_lines
  # POST /rblock_lines.xml
  def create
    @rblock_line = RblockLine.new(params[:rblock_line])

    respond_to do |format|
      if @rblock_line.save
        flash[:notice] = 'RblockLine was successfully created.'
        format.html { redirect_to(@rblock_line) }
        format.xml  { render :xml => @rblock_line, :status => :created, :location => @rblock_line }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rblock_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rblock_lines/1
  # PUT /rblock_lines/1.xml
  def update
    @rblock_line = RblockLine.find(params[:id])

    respond_to do |format|
      if @rblock_line.update_attributes(params[:rblock_line])
        flash[:notice] = 'RblockLine was successfully updated.'
        format.html { redirect_to(@rblock_line) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rblock_line.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rblock_lines/1
  # DELETE /rblock_lines/1.xml
  def destroy
    @rblock_line = RblockLine.find(params[:id])
    @rblock_line.destroy

    respond_to do |format|
      format.html { redirect_to(rblock_lines_url) }
      format.xml  { head :ok }
    end
  end

  def new_ajax_rblock_line
    #@rblock_line = RblockLine.new(:content_id => params[:content_id])
    fire_log params[:rblock_line], 'params[:rblock_line]'
    @rblock_line = RblockLine.new(params[:rblock_line])
    render :template => 'rblock_lines/new_rblock_line'
  end

  def create_ajax_rblock_line
    fire_log params[:rblock_line], 'params[:rblock_line]'
    @rblock_line = RblockLine.new(params[:rblock_line])
    @rblock_line.content.rblock_lines << @rblock_line
    #@rblock_line.content.paper.got_updated session[:user]
    if params[:insert_after_rbl] && params[:insert_after_rbl] != 'is_first' 
      position = RblockLine.find(params[:insert_after_rbl]).position + 1
      @rblock_line.insert_at( position )
    end
    render :template => 'rblock_lines/update_rblock_line', :locals => { :html_id => 'new' }
  end

  def create_ajax_pagebreak # should be done in create_ajax_rblock_line
    @rblock_line = RblockLine.new(params[:rblock_line])
    @rblock_line.kind = 'pagebreak' # should be submitted by the request
    @rblock_line.text = '0.5'			# same same
    @rblock_line.content.rblock_lines << @rblock_line
    #@rblock_line.content.paper.got_updated session[:user]
    if params[:insert_after_rbl] && params[:insert_after_rbl] != 'is_first' 
      position = RblockLine.find(params[:insert_after_rbl]).position + 1
      @rblock_line.insert_at( position )
    end
    render :template => 'rblock_lines/rblock_pagebreak', :locals => { :html_id => 'new' }
  end

  def edit_ajax_rblock_line
    @rblock_line = RblockLine.find(params[:id])
    render :template => 'rblock_lines/edit_rblock_line'
  end

  def cancel_ajax_rblock_line
    @rblock_line = RblockLine.find(params[:id])
    render :template => 'rblock_lines/cancel_rblock_line'
  end

  def update_ajax_rblock_line
    @rblock_line = RblockLine.find(params[:id])
    @rblock_line.update_attributes(params[:rblock_line])
    #@rblock_line.content.paper.got_updated session[:user]
    render :template => 'rblock_lines/update_rblock_line', :locals => { :html_id => params[:id] }
  end

  def destroy_ajax_rblock_line
    @rblock_line = RblockLine.find(params[:id])
    @rblock_line.destroy
    #@rblock_line.content.paper.got_updated session[:user]
    render :template => 'rblock_lines/delete', :locals => { :model => 'rblock_line', :content_id => @rblock_line.content_id }
  end
  
  def change_scale
    @rblock_line = RblockLine.find(params[:id])
    if @rblock_line.update_attribute :text, params[:value]
      render :nothing => true
    else
      render :template => 'common/alert', :locals => {:message => 'irnkwat läuft hier schief'}
    end
  end

  def order_items
    params[:items].each_with_index do |rbl_id, pos|
      RblockLine.find(rbl_id).update_attribute(:position, pos)
    end
    render :nothing => true
  end

  def abschlag
    @rblock_line = RblockLine.find(params[:id])
    @rblock_line.update_attribute(:price, @rblock_line.price / (1 + @rblock_line.tax_rate / 100))
    render :template => 'rblock_lines/abschlag'
  end
  
  protected
end
