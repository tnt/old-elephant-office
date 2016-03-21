# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#require 'firephruby'
#require "open-uri"
#require 'prawn'

DOC_CLASSES = {
  'Talk' => Talk,
  'PhoneCall' => PhoneCall,
  'Visit' => Visit,
  'Email' => Email,
  'Paper' => Paper
}

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  include UserInfo
  #include FirePHP
  include FirePhruby
  #include Constants
  
  #fire_options :mask_ruby_types => true,
  #    :processor_url => 'http://banza.net/firephruby/RequestProcessor.js',
  #  	:renderer_url => 'http://banza.net/firephruby/Renderer.js'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '3efc81e4bbd910c43b961620b88212fa'
  
  before_filter :authenticate
  before_filter :set_user
  
  before_filter :set_open_invoices_count

  before_filter :set_unseen_emails_count

  before_filter :set_last_customers_for_all

  protected
  
  def authenticate
    if User.find_by_id(session[:user]).nil?
      reset_session
      tct_logger.info "Kackomat 3000 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1#{request.format.jsonrs?} #{request.format}"
      #render :template => 'authentication/login.jsonrs' if request.format.jsonrs?
      session[:previous_uri] = request.fullpath unless request.format.jsonrs?
      redirect_to :controller => 'authentication', :action => 'login', :format => ( request.format.jsonrs? && :jsonrs )
    end
  end

  def set_open_invoices_count
    @open_invoices_count = Document.open_invoices.count
  end

  def set_unseen_emails_count email=nil
    email.update_attribute(:seen, true) if email
    @unseen_emails_count = Email.unseen_emails.count
  end

  def set_last_customers_for_all
    last_customers = cookies[:last_customers] ? cookies[:last_customers].split(',') : []
    #tct_logger.info "last_customers: #{last_customers}"
    lcsh = Hash[Customer.where(:id => last_customers).map {|c| [c.id, c]}]
    @last_customers = last_customers.map {|c| lcsh[c.to_i]}.reject {|c| c.nil?}
    #tct_logger.info "@last_customers: #{@last_customers.map {|c| c.id}}"
  end
  
  def md5(pass)
    Digest::MD5.hexdigest("--salz--#{pass}")
  end
  
  # Sets the current user into a named Thread location so that it can be accessed
  # by models and observers
  def set_user
    UserInfo.current_user = session[:user]
  end

  def german_date date
    #'%d.%d.%d' % .to_s.split('-').reverse.map {|s| s.to_i}
    date.strftime('%d.%m.%y').gsub(/0(\d\.)/, '\1')
  end
  
  def tct_logger
	  Rails.taciturn_logger
  end


  #around_filter :you_dont_have_bloody_clue


  def you_dont_have_bloody_clue
    klasses = [ActiveRecord::Base, ActiveRecord::Base.class]
    methods = ["session", "cookies", "params", "request"]

    methods.each do |shenanigan|
      oops = instance_variable_get(:"@_#{shenanigan}") 

      klasses.each do |klass|
        klass.send(:define_method, shenanigan, proc { oops })
      end
    end

    yield

    methods.each do |shenanigan|      
      klasses.each do |klass|
        klass.send :remove_method, shenanigan
      end
    end

  end
end

