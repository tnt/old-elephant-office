ThinkingSphinx::Index.define :paper, :with => :active_record do
  indexes :subject
  indexes :message
  indexes :remark
  indexes contents.text, :as => :content
  indexes contents.rblock_lines.text, :as => :rb_content
  # indexes address.customer.name, :as => :customer_name
  # indexes address.customer.remark, :as => :customer_remark
  # indexes [ address.title, address.firstname, address.name ], :as => :address_name
  # indexes [ address.specific.city, address.specific.street, address.specific.country, address.specific.line2, address.specific.line3, address.specific.zip ], :as => :address_address
  has :date
end