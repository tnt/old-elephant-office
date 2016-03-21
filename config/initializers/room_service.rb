# coding: utf-8

class RoomServiceHandler
  def self.logger
    @logger ||= Logger.new Rails.root.to_s + '/log/rs_handler.log' #ActionController::Base.logger
  end
  
  def self.call(template)
    'controller.lookup_context.update_details(:formats => [:html]) ' + 
    "{ eval(%q(#{template.source})).to_json.html_safe }"
  end
end

ActionView::Template.register_template_handler :jrs, RoomServiceHandler

#module ActionView
#  class LookupContext
#    alias old_formats_equals formats=
#    def formats=(values)
#      if values && values.size == 1
#        old_formats_equals(values)
#        values << :html if values.first == :jsonrs
#      end
#    end
#  end
#end
        