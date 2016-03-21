class ChangeEmailAttachmentsRenamePaperIdDocumentId < ActiveRecord::Migration
  def up
    rename_column :email_attachments, :paper_id, :document_id
  end

  def down
    rename_column :email_attachments, :document_id, :paper_id
  end
end
