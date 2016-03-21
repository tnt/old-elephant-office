ThinkingSphinx::Index.define :customer, :with => :active_record do
  indexes :name
  indexes :remark
  indexes contactables.name, :as => :cont_name
  indexes contactables.firstname, :as => :cont_firstname
  indexes contactables.remark, :as => :cont_remark
  indexes contents.rblock_lines.text, :as => :rb_content
end