class AddOurSignAndSigningLineToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.change :short_name, :text, :null => false, :default => ''
      t.rename :short_name, :signing_line
      t.string :our_sign, :null => false, :default => ''
      t.text :our_contact, :null => false, :default => ''
    end
  end
  def down
    change_table :users do |t|
      t.rename :signing_line, :short_name
      t.change :short_name, :string
      t.remove :our_sign
      t.remove :our_contact
    end
  end
end
