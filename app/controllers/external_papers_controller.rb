class ExternalPapersController < DocumentsController
  def create
    @document = params[:type].constantize.new(params[params[:type].underscore.to_sym], :without_protection => false)\
      if %w(Paper Email PhoneCall Visit ExternalPaper).include? params[:type]
    @document.set_user_info session[:user]
    ExternalPaper.save_upload(params['external_paper'][:file_ADP], @document) if params['external_paper'][:file_ADP]
    # @document.file =  params['external_paper'][file_ADP]
    tct_logger.info "@document.inspect: #{@document.inspect}\n params.inspect: #{params.inspect}"
    tct_logger.info params['external_paper']

    respond_to do |format|
      if @document.save params['external_paper']
        flash[:notice] = "#{@document.type} wurde gespeichert."
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
end
