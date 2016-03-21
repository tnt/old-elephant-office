# coding: utf-8
class ContentsController < ApplicationController
  respond_to :html, :json
  # GET /contents
  # GET /contents.xml
  def index
    @contents = Content.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
    end
  end

  # GET /contents/1
  # GET /contents/1.xml
  def show
    @content = Content.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content }
    end
  end

  # GET /contents/new
  # GET /contents/new.xml
  def new
    @content = Content.new

  end

  # GET /contents/1/edit
  def edit
    @content = Content.find(params[:id])
  end

  # POST /contents
  # POST /contents.xml
  def create
    @content = Content.new(params[:content])

    respond_to do |format|
      if @content.save
        flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to(@content) }
        format.xml  { render :xml => @content, :status => :created, :location => @content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contents/1
  # PUT /contents/1.xml
  def update
    @content = Content.find(params[:id])

    respond_to do |format|
      if @content.update_attributes(params[:content])
        flash[:notice] = 'Content was successfully updated.'
        format.html { redirect_to(@content) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.xml
  def destroy
    @content = Content.find(params[:id])
    @content.destroy

    respond_to do |format|
      format.html { redirect_to(contents_url) }
      format.xml  { head :ok }
    end
  end
  
  def new_ajax_content
    #@content = Content.new(:document_id => params[:document_id], :kind => params[:kind])
    @content = Content.new(params[:content])
    fire_log params[:content], 'params[:content]'
    render :template => 'contents/new_content'
  end

  def create_ajax_content
    @content = Content.new(params[:content])
    @content.paper.contents << @content
    if params[:insert_after] && params[:insert_after] != 'is_first' 
      position = Content.find(params[:insert_after]).position + 1
      @content.insert_at( position )
    end
    render :template => "contents/create_content", :locals => { :html_id => 'new' }
  end

  def create_ajax_pagebreak
    @content = Content.new(params[:content])
    @content.kind = 'pagebreak'
    @content.text = '0.5'
    @content.paper.contents << @content
    if params[:insert_after] && params[:insert_after] != 'is_first' 
      position = Content.find(params[:insert_after]).position + 1
      @content.insert_at( position )
    end
    render :template => "contents/pagebreak", :locals => { :content => @content }
  end

  def create_pagebreak
    @content = Content.new(:paper_id => params[:paper_id], :kind => 'pagebreak', :text => '0.5')
    @content.paper.contents << @content
    if params[:insert_after] && params[:insert_after] != 'is_first' 
      position = Content.find(params[:insert_after]).position + 1
      @content.insert_at( position )
    end
  end

  def edit_ajax_content
    @content = Content.find(params[:id])
    #render :partial => "edit_#{params[:kind]}"
    render :template => "contents/edit_content"
  end
  
  def cancel_ajax
    @content = Content.find(params[:id])
    render :template => "contents/cancel_content"
  end
  
  def update_ajax_content # for the form
    @content = Content.find(params[:id])
    if @content.update_attributes(params[:content])
      render :template => "contents/update_content", :locals => { :html_id => params[:id] }
    end
  end
  
  def reset_signer
    @content = Content.find(params[:id])
    user = User.find current_user
    if @content.update_attributes(:text => user.signing_line, :signer => current_user)
      render :template => "contents/update_content", :locals => { :html_id => params[:id] }
    end
  end

  def destroy_ajax_content
    @content = Content.find(params[:id])
    @content.destroy
    if @content.paper.contents.length > 0 
      render :template => 'contents/delete_content_line'
    else
      render :template => "contents/insert_first_content"
    end
  end
  
  def change_scale
    @content = Content.find(params[:id])
    if @content.update_attribute :text, params[:value]
      render :nothing => true
    else
      render :nothing => true, :status => 404
    end
  end

  def order_items
    params[:items].each_with_index do |content_id, pos|
      Content.find(content_id).update_attribute(:position, pos)
    end
    render :nothing => true
  end
end
