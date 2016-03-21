# coding: utf-8
module EmailHelper
  #include DocumentsHelper

  def contactable_selector f
    document = f.object
    document.customer.current_email_addresses.count > 1 ?
            f.select(:address_id, document.customer.current_email_addresses.map {|em| [em.email_address_complete,em.id]}) :
            render(:partial => 'email_addresses/contactable_line', :locals => {:contactable => document.email_address}) + f.hidden_field(:address_id) 
  end
  def js_form_variable_paper
    content_for :js_declarations do
      "form_templates['paper'] = \"#{escape_javascript(render(:template => "email_attachments/_paper_form", :locals => {:f => EmailAttachment.new({:kind => 'paper'})}))}\";"
    end
  end
  def add_file_attachment_link caption
    link_to_function caption do |page|
      page.insert_html :bottom, :attachments, {:partial => 'email_attachments/file_upload'}, EmailAttachment.new
    end
  end
  def add_doc_attachment_link caption, address_id
    rs_link_to caption, 
      { :controller => 'email_attachments', :action => 'document_choice', :address_id =>address_id }, 
      'data-loading-element' => 'attachment_adder_container', :id => :add_attachment_link
  end
end
