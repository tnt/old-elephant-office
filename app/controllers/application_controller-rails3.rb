class ApplicationController < ActionController::Base
  protect_from_forgery
end
#require 'prawn/layout'
#module Prawn
#  module Format
#    module Instructions
#      class Text < Base
#        def initialize(state, text, options={})
#          super(state)
#          @text = text
#          @break = options.key?(:break) ? options[:break] : text.index(/[-\xE2\x80\x94\s]/)
#          @discardable = options.key?(:discardable) ? options[:discardable] : text.index(/\s/)
#          @text = state.font.normalize_encoding(@text) if options.fetch(:normalize, true)
#        end
#      end
#    end
#  end
#	module Images
#    def detect_image_format(content) # evil hack for incompatibility of prawn 0.6.3 with ruby 1.9
#        return :png
#    end
# 	end
#end
#module ActionMailer
#  class Base
#    def perform_delivery_smtp(mail)
#      destinations = mail.destinations
#      mail.ready_to_send
#      sender = (mail['return-path'] && mail['return-path'].spec) || Array(mail.from).first

#      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
#      smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
#      smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
#                 smtp_settings[:authentication]) do |smtp|
#        smtp.sendmail(mail.encoded, sender, destinations)
#      end
#    end
#  end
#end
