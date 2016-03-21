class OldDoc < ActiveRecord::Base
  default_scope order([:customer,:date])

  before_destroy do |od|
    path = File.join(Rails.root, 'public', file_url)
    File.delete path if File.exists? path
  end

  def self.search(search)
    if search
        self.where(['"old_docs"."customer" ilike ?', "%#{search}%"])
    else
      self.scoped
    end
  end
  def prev
    OldDoc.where("(customer = ? AND date < ?) OR customer < ?", customer, date, customer).last
  end
  def next
    OldDoc.where("(customer = ? AND date > ?) OR customer > ?", customer, date, customer).first
  end
  def file_url
    "/old_documents/#{filename}"
  end
end
