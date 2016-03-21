#!/usr/local/bin/ruby

require 'rufus/scheduler'
require 'logger'
require File.expand_path('../../config/environment.rb',  __FILE__)

#pid_fh = File.open(File.expand_path('../../tmp/pids/mail_checker.pid',  __FILE__), 'w')
#pid_fh.write(Process.pid.to_s)
#pid_fh.close

EmailChecker.logger = Logger.new File.expand_path('../../log/mail_check.log',  __FILE__), 10, 1024000
log = EmailChecker.logger
log.datetime_format = "%Y-%m-%d %H:%M:%S"
log.formatter = proc { |severity, datetime, progname, msg|
  "#{datetime}: #{msg}\n"
}
log.level = Logger::DEBUG

scheduler = Rufus::Scheduler.start_new

scheduler.every '2m', :blocking => true, :first_in => '0s' do
  log.info  "ENV['RAILS_ENV']: '#{ENV['RAILS_ENV']}' - checking for new mails..."
  EmailChecker.check_mails
  log.info  "incoming mail check done. checking outgone emails..."
  EmailChecker.check_mails :is_foreign => false
  log.info  "mail check done."
end

scheduler.join
  