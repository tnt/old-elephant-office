# coding: utf-8
class InvoiceStuff
  include ElphConfig
  
  def initialize(paper)
    @paper = paper
  end
  
  def is_invoice?
    Elph[:inv_kinds].include? @paper.kind
  end
  
  def update_value amount
    @paper.update_attribute(:value, amount)
    update_cash_book
  end
  
  def update_cash_book
    @paper.cash_book.update_attribute(:amount, @paper.value) if @paper.cash_book
  end
  
  def set_invoice_number
    return unless is_invoice?
    i_number = InvoiceNumber.find_or_create_by_year Date.today.year
    i_number.update_attribute :number, i_number.number.to_i + 1
    @paper.invoice_number = i_number.number
  end

  def last_invoice_of_year
    return nil unless is_invoice?
    Paper.find :first, :conditions => "date_part('year',date)='#{i_number.year.to_s}' AND invoice_number='#{i_number.number}'", :include => :address
  end
end
