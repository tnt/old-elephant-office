#!/usr/bin/env /usr/local/rvm/bin/ruby
# coding: utf-8

require 'cgi'
require 'yaml'
YAML::ENGINE.yamler= 'syck'
require 'net/smtp'
require 'date'
require 'digest/md5'

cgi = CGI.new

Elph = YAML.load(File.read('../../config/elph_conf.yml'))['production']
settings = Elph[:report_mail_settings]

error_info = {
  '404' => { 
    :title => 'Fehler 404: Die gewünschte Resource wurde nicht gefunden',
    :explanation => ''
  },
  '422' => { 
    :title => 'Fehler 422: Die gewünschte Änderung wurde verweigert',
    :explanation => ''
  },
  '500' => { 
    :title => 'Fehler 500: Interner Server Fehler',
    :explanation => ''
  }
}[cgi['errorcode']]

logfile_hash = cgi['logfile_hash'].empty? ? Digest::MD5.hexdigest(rand(1234567).to_s).to_s : cgi['logfile_hash']
#`tail -300 ../../log/production.log > log/#{logfile_hash}.log` if cgi['logfile_hash'].empty? 
system("tail -300 ../../log/production.log > log/#{logfile_hash}.log") if cgi['logfile_hash'].empty? 
log_content = File.read("log/#{logfile_hash}.log", :encoding => 'utf-8')

template = File.read('form.html', :encoding => 'utf-8')
template.sub! '{self}', ($0).sub(/.*\//,'')
template.sub! '{logfile_hash}', logfile_hash
#template.sub! '{log_content}', log_content
template.gsub! '{title}', error_info[:title]
template.gsub! '{errorcode}', cgi['errorcode']

unless cgi['send'].empty?
  template.sub! '{success}', 'Yeah'
  template.sub! '{message}', ''
  mail = <<END_OF_MESSAGE
From: #{settings[:from]}
To: #{settings[:to]}
Subject: Fehler #{cgi['errorcode']}
Date: #{Time.now.asctime}
Content-Type: text/plain; charset=UTF-8

#{cgi['message']}

#{log_content}
END_OF_MESSAGE
  begin
    smtp = Net::SMTP.new settings[:host], settings[:port]
    smtp.enable_starttls if settings[:starttls]
    smtp.start unless settings[:auth]
    smtp.start('', settings[:username], settings[:password], settings[:auth]) if settings[:auth]
    smtp.send_message(mail,settings[:from], settings[:to])
    smtp.finish
    template.sub! '{dialog_class}', 'success'
  rescue
    template.sub! '{dialog_class}', 'failure'
  end
else
  template.sub! '{dialog_class}', 'unsent'
  template.sub! '{message}', cgi['message']
end

puts cgi.header(:status => cgi['errorcode'], 'type' => 'text/html; charset=utf-8')
puts template
