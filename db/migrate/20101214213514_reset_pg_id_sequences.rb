class ResetPgIdSequences < ActiveRecord::Migration
  def self.up
  	tables_not_to_migrate = ['schema_migrations']
  	(tables - tables_not_to_migrate).each {|t| execute "select setval('#{t}_id_seq', (select max(id) + 1 from #{t}))"}
  end

  def self.down
  end
end
