# coding: utf-8
class AuthenticationController < ApplicationController
  skip_filter :authenticate
  
  def sign_on
    
    user = User.find( :first, 
                :conditions => [ 'username = ? and password = ?',
                params[:username], md5( params[:password] ) ] )

    if user
      session[:user] = user.id
      # redirect_to users_url
      # redirect_to :back
      #ActiveRecord::Base.connection.execute 'DELETE FROM sessions WHERE updated_at < DATE_SUB(CURDATE(), INTERVAL 3 DAY);' 
      ActiveRecord::Base.connection.execute 'DELETE FROM sessions WHERE updated_at < current_date -  INTERVAL \'1 day\';' 
  
      if session[:previous_uri] and session[:previous_uri] != request.fullpath
        redirect_to session[:previous_uri]
      else
        redirect_to '/'
      end
    else
      render :action => 'login'
    end
  end
  
  #def login
  #	fire_log 'AuthenticationController.login happend to be executed'
  #	session[:client_time_offset] = 0
  #end

  def logout
    reset_session
    redirect_to :action => 'login'
  end
end
