# coding: utf-8
class Content < ActiveRecord::Base
  #attr_accessible :updated_at, :text
  belongs_to :paper#, :touch => true
  acts_as_list :scope => :paper_id, :top_of_list => 0
  has_many :rblock_lines, :dependent => :destroy, :order => 'position'
  validates_inclusion_of :kind, :in => %w(text rblock pagebreak signing)
  delegate :tax_rate, :document_updated, :update_value, :to => :paper
  scope :rblocks, where(:kind => :rblock)

  after_save { document_updated } # gets set by :touch => true

  text_hyphen :text, left: 2

  def sum
    @sum ||= self.rblock_lines.sum :price
  end
  def tax taxrate=nil
    taxrate ||=  tax_rate
    sum  * taxrate / 100
  end
  def total taxrate=nil
    sum + tax(taxrate)
  end

  def text_with_breaks
    self.text.gsub(/\n+/, '<br>').html_safe
  end

  def text_with_spacing
    self.text.gsub(/^ +/) {|sp| '&nbsp;' * sp.length}.gsub(/\n+/, '<br>').html_safe
  end

  def text_with_indent
    self.text.gsub(/^ +/) {|sp| "\u00A0#{sp}"}.html_safe
  end

  protected

end
