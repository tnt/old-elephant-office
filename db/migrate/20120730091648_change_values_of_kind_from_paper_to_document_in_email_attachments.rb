class ChangeValuesOfKindFromPaperToDocumentInEmailAttachments < ActiveRecord::Migration
  def up
    EmailAttachment.where(:kind => :paper).update_all(:kind => 'document')
  end

  def down
  end
end
