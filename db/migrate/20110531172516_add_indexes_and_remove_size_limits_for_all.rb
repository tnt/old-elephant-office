class AddIndexesAndRemoveSizeLimitsForAll < ActiveRecord::Migration
  def self.up
    change_table "address_specifics" do |t|
      t.change "line2", :string
      t.change "line3", :string
      t.change "street", :string
      t.change "number", :string
      t.change "zip", :string
      t.change "city", :string
      t.change "country", :string
      t.change "state", :string
      t.index :delivery_address
      t.index :invoice_address
    end
    
    change_table "contactables" do |t|
      t.change "type", :string
      t.index "type"
    end

    change_table "contents" do |t|
      t.change "template_item", :boolean, :default => false
      t.index [:paper_id, :position]
      t.index :paper_id
    end
  
    change_table "customers" do |t|
      t.change "asshole", :boolean,             :default => false
      t.change "name_phonetic_codes", :string, :default => ""
      t.remove "email"
    end
  
    change_table "documents" do |t|
      t.change "is_foreign", :boolean,                                           :default => false
      t.change "self_generated_email", :boolean,                                 :default => false

      t.index  "address_id"
      t.index "date"
      t.index "is_foreign"
      t.index  ["imap_server", "imap_uid"]
      t.index "seen"
    end
  
    change_table "documents_documents" do |t|
      t.index "linker_id"
      t.index "linkee_id"
    end

    change_table "email_address_specifics" do |t|
      t.change "email", :string

      t.index "email_address_id"
      t.index "email"
    end
  
    change_table "email_attachments" do |t|
      t.change "image", :boolean,          :default => false
      t.change "alternate_part", :boolean, :default => false
      t.change "inline", :boolean,         :default => false

      t.index "email_id"
      t.index "paper_id"
      t.index "position"
    end
  
    change_table "invoice_numbers" do |t|
      t.change "number", :integer, :default => 0
    end
  
    change_table "person_specifics" do |t|
      t.index "person_id"
    end
  
    change_table "phone_number_specifics" do |t|
      t.change "number", :string
      t.change "kind", :string
      t.index  "norm_number"
      t.index "phone_number_id"
    end
  
    change_table "rblock_lines" do |t|
      t.change "kind", :string, :default => "line"
      t.index  "position"
    end
  
    change_table "users" do |t|
      t.change "admin", :boolean,                    :default => false
      t.change "system", :boolean,                   :default => false
      t.change "short_name", :string
    end
  end

  def self.down
    change_table "address_specifics" do |t|
      t.remove_index :delivery_address
      t.remove_index :invoice_address
    end

    change_table "contactables" do |t|
      t.remove_index "type"
    end

    change_table "contents" do |t|
      t.remove_index [:paper_id, :position]
      t.remove_index :paper_id
    end
  
    change_table "customers" do |t|
      t.add_column "email", :string
    end
  
    change_table "documents" do |t|
      t.remove_index  "address_id"
      t.remove_index "date"
      t.remove_index "is_foreign"
      t.remove_index  ["imap_server", "imap_uid"]
      t.remove_index "seen"
    end
  
    change_table "documents_documents" do |t|
      t.remove_index "linker_id"
      t.remove_index "linkee_id"
    end

    change_table "email_address_specifics" do |t|
      t.remove_index "email_address_id"
      t.remove_index "email"
    end
  
    change_table "email_attachments" do |t|
      t.remove_index "email_id"
      t.remove_index "paper_id"
      t.remove_index "position"
    end
  
    change_table "person_specifics" do |t|
      t.remove_index "person_id"
    end
  
    change_table "phone_number_specifics" do |t|
      t.remove_index  "norm_number"
      t.remove_index "phone_number_id"
    end
  
    change_table "rblock_lines" do |t|
      t.remove_index  "position"
    end
  end
end
