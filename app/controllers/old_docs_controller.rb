class OldDocsController < ApplicationController
  # GET /old_docs
  # GET /old_docs.json
  def index
    @old_docs = OldDoc.scoped
    @old_docs = @old_docs.search(params[:search]) unless params[:search].blank?
    @old_docs = @old_docs.page(params[:page]).per(50)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @old_docs }
    end
  end

  # GET /old_docs/1
  # GET /old_docs/1.json
  def show
    @old_doc = OldDoc.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @old_doc }
    end
  end

  # GET /old_docs/new
  # GET /old_docs/new.json
  def new
    @old_doc = OldDoc.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @old_doc }
    end
  end

  # GET /old_docs/1/edit
  def edit
    @old_doc = OldDoc.find(params[:id])
  end

  # POST /old_docs
  # POST /old_docs.json
  def create
    @old_doc = OldDoc.new(params[:old_doc])

    respond_to do |format|
      if @old_doc.save
        format.html { redirect_to @old_doc, notice: 'Old doc was successfully created.' }
        format.json { render json: @old_doc, status: :created, location: @old_doc }
      else
        format.html { render action: "new" }
        format.json { render json: @old_doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /old_docs/1
  # PUT /old_docs/1.json
  def update
    @old_doc = OldDoc.find(params[:id])

    respond_to do |format|
      if @old_doc.update_attributes(params[:old_doc])
        # format.html { redirect_to @old_doc, notice: 'Old doc was successfully updated.' }
        flash[:notice] = 'Old doc was successfully updated.'
        format.html { redirect_to :back }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @old_doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /old_docs/1
  # DELETE /old_docs/1.json
  def destroy
    @old_doc = OldDoc.find(params[:id])
    @old_doc.destroy

    respond_to do |format|
      flash[:notice] = 'Old doc was destroyed.'
      format.html { redirect_to Rails.application.routes.url_helpers.edit_old_doc_path @old_doc.next }
      # format.html { redirect_to old_docs_url }
      format.json { head :ok }
    end
  end
end
