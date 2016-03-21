# coding: utf-8
module PhoneNumberNormize

  def self.included(base)
    puts 'extending #{base.class.name}'
    base.extend(self)
  end
  
  include ElphConfig
  
  def _normize_number num_str
    prefix = Elph[:phone_country_pref] + Elph[:phone_local_pref] 
    _strip_deco(num_str).sub(/^00/,'+').sub(/^0/, Elph[:phone_country_pref]).sub(/^(?=\d)/, prefix)
  end
  
  def _strip_deco num_str
    num_str.gsub(/[^+\d]+/,'')
  end
end