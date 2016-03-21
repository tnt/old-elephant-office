
# if Rails.version == "3.1.12"
if ActiveRecord::Base.instance_methods(false).include? :dup
  module ActiveRecord 
      class Base
          remove_method :dup
      end
  end
end