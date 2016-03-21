#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

doc_templates = [
  {:kind => 'barrechnung', :subject => '',
   :contents => [
                 {:kind => 'rblock', :text => ''},
                 {:kind => 'text', :text => ''},
                 {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                 {:kind => 'signing', :text => '#{user_signing_line}'}
                ]},
  {:kind => 'rechnung', :subject => '',
   :contents => [
                 {:kind => 'rblock', :text => ''},
                 {:kind => 'text', :text => ''},
                 {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                 {:kind => 'signing', :text => '#{user_signing_line}'}
                ]},
  {:kind => 'kostenvoranschlag', :subject => '',
   :contents => [
                 {:kind => 'rblock', :text => ''},
                 {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                 {:kind => 'signing', :text => '#{user_signing_line}'}
                ]},
  {:kind => 'brief', :subject => '',
   :contents => [
                 {:kind => 'text', :text => %q(Sehr geehrte#{address_sex=='male'?'r':''} #{address_sex=='neutral'? 'Damen und Herren' : "#{address_sex=='male' ? 'Herr' : 'Frau'} #{address_name}"})},
                 {:kind => 'text', :text => ''},
                 {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                 {:kind => 'signing', :text => '#{user_signing_line}'}
                ]},

  {:kind => 'angebot', :subject => 'Ihre Anfrage vom #{german_date Date.today}',
   :contents => [
                 {:kind => 'text', :text => %q(Sehr geehrte#{address_sex=='male'?'r':''} #{address_sex=='neutral'? 'Damen und Herren' : "#{address_sex=='male' ? 'Herr' : 'Frau'} #{address_name}"})},
                 {:kind => 'text', :text => ''},
                 {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                 {:kind => 'signing', :text => '#{user_signing_line}'}
                ]},

  {:kind => 'mahnung', :subject => 'Rechnung #{ref_paper_invoice_number_formatted} vom #{german_date ref_paper_date}',
   :contents => [
                 {:kind => 'text', :text => %q(Laut unserer Buchführung sind noch #{ref_paper_value_formatted} aus der oben genannten Rechnung offen#{%Q( (dies ist bereits die #{['zweite','dritte'][ref_paper_dun_times?-1]} Erinnerung)) if ref_paper_dun_times? > 1}. Sollten Sie diese Rechnung innerhalb der letzten Tage bezahlt haben, betrachten Sie dieses Schreiben bitte als gegenstandslos.)},
                  {:kind => 'text', :text => 'Sollten Sie die Rechnung schon vor längerer Zeit beglichen haben, entschuldigen wir uns vielmals und bitten Sie, uns gelegentlich das Datum ihrer Überweisung wissen zu lassen, damit wir Sie nicht länger automatisch weiter mahnen.'},
                  {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                  {:kind => 'signing', :text => '#{user_signing_line}'}
                  ]},

  {:kind => 'wertbestätigung', :subject => '',
    :contents => [
    {:kind => 'text', :text => %q(Sehr geehrte#{address_sex=='male'?'r':''} #{address_sex=='neutral'? 'Damen und Herren' : "#{address_sex=='male' ? 'Herr' : 'Frau'} #{address_name}"})},
                  {:kind => 'text', :text => ''},
    {:kind => 'text', :text => 'Mit freundlichen Grüßen'},
                  {:kind => 'signing', :text => '#{user_signing_line}'}
    ]}
]


# pw = 'ce2182bea280aad7d6515d7ba2445e32' # 'password'
pw = 'password'

ActiveRecord::Base.transaction do


  users = User.create([{:username => 'system', :admin => false, :system => true, :signing_line => '', :our_sign => '', :our_contact => '', :password => pw},
                     {:username => 'admin', :admin => true, :system => false, :signing_line => '', :our_sign => '', :our_contact => '', :password => pw}])

  system_user = users[0]

  puts system_user

  UserInfo.current_user = system_user.id

  system_customer = Customer.create([{name: 'System'}])[0]
  # ctbl = Address.create([{sex: 'neutral', name: 'Template Address', remark: 'for paper templates'}])[0]
  ctbl = Address.new(sex: 'neutral', name: 'Template Address', remark: 'for paper templates', specific_attributes: {zip: ''})
  system_customer.contactables << ctbl

  td = Date.today

  doc_templates.each do |dt|
    puts dt[:kind]
    d = Paper.new :kind => dt[:kind], :subject => dt[:subject], :date => td
    d.update_attribute :system, true
    d.update_attribute :user, system_user
    dt[:contents].each do |ct|
      c = Content.new :kind => ct[:kind], :text => ct[:text]
      d.contents << c
    end
    ctbl.papers << d
  end

end

puts "add the following to elph_conf.yml for 'doc_templates':"
puts Hash[*(Customer.first.contactables.first.documents.map {|p| [p.kind, p.id]}.flatten)].to_yaml.gsub("\n", ', ')
