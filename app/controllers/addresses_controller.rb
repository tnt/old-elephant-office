# coding: utf-8
class AddressesController < ContactablesController
  def set_delivery_invoice
    @address = Contactable.find(params[:id])
    if %w(invoice_address delivery_address).include? params[:attribute]
      attributes = @address.set_delivery_invoice params[:attribute]
      render :template => 'addresses/set_single_attribute', :locals => { :attributes => attributes }
    else
      render :template => 'common/alert', :locals => { :message => 'Ohne sowat, bitte!' }
    end
  end
end
