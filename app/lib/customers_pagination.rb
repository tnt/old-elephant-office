module CustomersPagination
  include ElphConfig

  def _customers_per_page
    @customers_per_page = params[:customers_per_page] || cookies[:customers_per_page] || Elph[:customers_per_page].to_s
    cookies[:customers_per_page] = { :value => @customers_per_page, :expires => 1.year.from_now }
    @customers_per_page
  end
end
