class PaperTemplateMacros
  include UserInfo
  include ApplicationHelper
  def initialize paper_template
    @paper = paper_template.paper
    @template = paper_template.template
    @ref_paper = paper_template.ref_paper
    @address = @paper.address
    @user = User.find current_user
  end
  def method_missing name
    " -|No such method: '#{name}'|- "
  end
  def self.define_methods prefix
    const_get("#{prefix.upcase}_METHODS").each do |m|
      define_method("#{prefix}_#{m.to_s}") { self.instance_variable_get("@#{prefix}").send(m) }
    end
  end
  PAPER_METHODS = %w(date invoice_number_formatted doc_name get_signer value_formatted state dun_times?)
  TEMPLATE_METHODS = PAPER_METHODS
  REF_PAPER_METHODS = PAPER_METHODS
  ADDRESS_METHODS = %w(sex title firstname name line2 line3 street number zip city country state)
  USER_METHODS = %w(signing_line)
  %w(paper template address user ref_paper).each {|p| define_methods p }
end
