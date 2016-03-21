# coding: utf-8
            
class PaperFileController < DocumentsController

  def index
    @papers = Paper.unfiled

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @papers }
    # end
  end

  def create
    @paper = Paper.find(params[:id])
    @paper.file
    # respond_to do |format|
    #   format.jsonrs
    # end
  end

  def destroy
    @paper = Paper.find(params[:id])
    @paper.unfile
  end
end


