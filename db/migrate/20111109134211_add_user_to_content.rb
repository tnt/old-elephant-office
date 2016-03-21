class AddUserToContent < ActiveRecord::Migration
  include UserInfo
  def up
    add_column :contents, :signer, :integer
    users = {}
    Paper.all.each do |p|
      uid = p.signed_by || p.user_id
      users[uid] ||= User.find uid
      UserInfo.current_user = p.last_modified_by
      updated = p.updated_at
      c = Content.create(:kind => 'signing', :signer => uid, :text => users[uid].signing_line, :position => p.contents.size+1, :paper_id => p.id)
      p.update_attribute :updated_at, updated
    end
  	Paper.where(:id => [20, 21, 22, 23, 24, 26, 25]).each do |p|
      p.contents.where(:kind => 'signing').first.update_attribute :text, "\#{user_signing_line}"
    end
  end
  def down
    remove_column :contents, :signer
    Content.where(:kind => :signing).destroy_all
  end
end
