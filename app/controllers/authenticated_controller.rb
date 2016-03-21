# coding: utf-8
class AuthenticatedController < ApplicationController
  def index
    # if not redirected, we're logged in
    render :text => session['_csrf_token']
  end
end


