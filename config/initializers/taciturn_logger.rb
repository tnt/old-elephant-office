# coding: utf-8

module Rails
  def self.taciturn_logger
    @tct_logger ||= Logger.new Rails.root.to_s + '/log/taciturn.log'
  end
end

class ActiveRecord::Base
  def tct_logger
    Rails.taciturn_logger
  end  
end
