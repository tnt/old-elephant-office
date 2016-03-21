# coding: utf-8

module PapersHelper
  include Prawn::Measurements
  include ElphConfig
  include ActionView::Helpers::NumberHelper
  
  def address_lines c
    al = []
    l23 = [ quote_amp(c.line2), quote_amp(c.line3) ]
    l23.each {|l| al << ' ' if l.nil? || l.empty? }
    al << quote_amp(c.full_name)
    l23.each {|l| al << l unless l.nil? || l.empty? }
    al << "#{c.street} #{c.number}" << "#{c.zip} #{c.city}" << c.country
  end
  
  def quote_amp str
    # str.gsub /&(?![\w#]+;)/,'&amp;' if str
    str   # somtimes we need it, sometimes not...
  end
end
