class Search
  attr_accessor :customers, :contactables, :documents

  def initialize(params)
    if params.include? 'search_pns'
      results = phone_number_search(params['search_adv'], params['search_pns_full'])
      @contactables = Contactable.where(id: results.map(&:phone_number_id).uniq)
      @customers = Customer.where(id: @contactables.map(&:customer_id).uniq)
    end
  end
  
  def phone_number_search(pn, full)
    PhoneNumberSpecific.search(pn, full)
  end
  
  def sphinx_search(s_str, models)
    
  end
end
