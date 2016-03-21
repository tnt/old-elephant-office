# coding: utf-8
class RblockLine < ActiveRecord::Base
  belongs_to :content #, :touch => true
  acts_as_list :scope => :content_id, :top_of_list => 0
  delegate :tax_rate, :document_updated, :update_value, :to => :content

  after_save :update_document
  after_destroy :update_document

  text_hyphen :text

  def update_document
    document_updated
    update_value content.total
  end
  
  def price= am
    unless am.is_a? Numeric or am.blank?
      am.gsub! /[^-\d,]+/,''
      am.tr! ',','.'
    end
    write_attribute(:price, am)
  end

  protected
end
