Elephant::Application.routes.draw do
  resources :old_docs

  resources :searches, :only => [:new, :create, :index]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  match 'email_tests/jason'
  resources :email_tests

  match 'cash_books/create_ajax' #=> 'cash_books#create_ajax'
  match 'cash_books/clear'
  resources :cash_books

  #resources :authentication, :collection => {:logout => :get, :sign_on => :get, :login => :get}
  match 'authentication/sign_on'
  match 'authentication/login'
  match 'authentication/logout'
  match 'authenticated' => 'authenticated#index'

  match 'documents/preview/:id' => 'documents#preview'
  match 'documents/address_choice/:id' => 'documents#address_choice'
  match 'documents/ajax_choice_linked'
  match 'documents/ajax_destroy_linked'
  match 'documents/ajax_create_linked'
  match 'documents/select_address/:id' => 'documents#select_address'
  match 'documents/destroy_ajax_document'
  resources :documents
  
  resources :document_aliases, :only => [:new, :create]

  match 'emails/unseen_emails' => 'emails#unseen_emails'
  match 'emails/seen/:id' => 'emails#seen'
  match 'emails/destroy_ajax_document'
  resources :emails

  match 'talks/destroy_ajax_document'
  resources :talks
  resources :phone_calls, :controller => :talks
  resources :visits, :controller => :talks

  match 'papers/file/:id(.:format)' => 'papers#file'
  match 'papers/unfile/:id(.:format)' => 'papers#unfile'
  match '/papers/open_invoices'
  match 'papers/change_scale/:id' => 'papers#change_scale'
  match 'papers/ajax_set_state_paid'
  match 'papers/dun_from_invoice'
  match 'papers/invoice_from_offer'
  match 'papers/invoices_from_offer'
  match 'papers/destroy_ajax_document/:id(.:format)' => 'papers#destroy_ajax_document'
  match 'papers/send_by_email/:id' => 'papers#send_by_email'
  resources :papers
  resources :paper_file, :only => [:index, :create, :destroy]
  #match 'filed_papers/:filename'

  match 'external_papers/destroy_ajax_document/:id(.:format)' => 'external_papers#destroy_ajax_document'
  match 'external_papers/send_by_email/:id' => 'external_papers#send_by_email'
  resources :external_papers

  match 'contents/new_ajax_content'
  match 'contents/create_ajax_pagebreak'
  match 'contents/create_pagebreak'
  match 'contents/create_ajax_content'
  match 'contents/edit_ajax_content'
  match 'contents/update_ajax_content'
  match 'contents/destroy_ajax_content'
  match 'contents/change_scale/:id' => 'contents#change_scale'
  match 'contents/order_contents'
  match 'contents/order_items'
  match 'contents/cancel_ajax'
  match 'contents/reset_signer'
  resources :contents

  match 'rblock_lines/abschlag'
  match 'rblock_lines/new_ajax_rblock_line'
  match 'rblock_lines/edit_ajax_rblock_line'
  match 'rblock_lines/update_ajax_rblock_line'
  match 'rblock_lines/cancel_ajax_rblock_line'
  match 'rblock_lines/create_ajax_pagebreak'
  match 'rblock_lines/create_ajax_rblock_line'
  match 'rblock_lines/destroy_ajax_rblock_line'
  match 'rblock_lines/order_items'
  match 'rblock_lines/change_scale/:id' => 'rblock_lines#change_scale'
  resources :rblock_lines

  match 'email_attachments/document_choice' => 'email_attachments#document_choice'
  match 'email_attachments/new_document' => 'email_attachments#new_document'
  match 'email_attachments/new_file'
  resources :email_attachments

  match 'contactables/add_document'
  match 'contactables/change'
  match 'contactables/mark_outdated'
  resources :contactables

  match 'addresses/set_delivery_invoice'
  resources :addresses
  resources :email_addresses
  resources :phone_numbers
  resources :people

  match 'customers/rstest'
  match 'customers/search' => 'customers#search'
  match 'customers/add_alias_form' => 'customers#add_alias_form'
  match 'customers/add_contactable_form' => 'customers#add_contactable_form'
  match 'customers/choice_reassign_address/:id(.:format)' => 'customers#choice_reassign_address'
  match 'customers/confirm_reassign_address/:id(.:format)' => 'customers#confirm_reassign_address'
  match 'customers/reassign_address/:id(.:format)' => 'customers#reassign_address'
  match 'customers/select_reassign_existing_contactable' => 'customers#select_reassign_existing_contactable'
  match 'customers/assign_existing_contactable_to_existing_customer/:id(.:format)' => 'customers#assign_existing_contactable_to_existing_customer'
  match 'customers/assign_existingcontactable_to_new_customer' => 'customers#assign_existing_contactable_to_new_customer'
  resources :customers

  resources :users

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "customers#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end
