# coding: utf-8
class CashBook < ActiveRecord::Base
  cfg = Rails.configuration.database_configuration[Rails.env].dup
  cfg['database'] = "cb_#{Rails.env}"
  establish_connection(cfg)

  belongs_to :paper

  scope :sale, :conditions => { :workshop => false }, :order => 'date asc'#, :include => :paper
  scope :workshop, :conditions => { :workshop => true }, :order => 'date asc'#, :include => :paper
  scope :in, :conditions => { :direction => 'in' }
  scope :out, :conditions => { :direction => 'out' }
  scope :till_month, lambda { |month,year| # including the given month
    { :conditions => "((date_part('month',date)<=#{month} AND date_part('year',date)<=#{year}) OR date_part('year',date)<#{year})" }
  }

  %w(in out).each do |m|
    %w(sale workshop).each do |n|
      scope "#{n}_#{m}", :conditions => { :workshop => (n=='workshop'), :direction => m }
      scope "#{n}_#{m}_old", :conditions => "workshop=#{n=='sale'?'false':'true'} AND direction='#{m}' AND (date_part('month',date)<date_part('month',now()) OR date_part('year',date)<date_part('year',now()))"
      scope "#{n}_#{m}_of_month", lambda { |month,year|
        { :conditions => "workshop=#{n=='sale'?'false':'true'} AND direction='#{m}' AND (date_part('month',date)=#{month} AND date_part('year',date)=#{year})" }
      }
      scope "#{n}_#{m}_till_month", lambda { |month,year|  # including the given month
        { :conditions => "workshop=#{n=='sale'?'false':'true'} AND direction='#{m}' AND ((date_part('month',date)<=#{month} AND date_part('year',date)<=#{year}) OR date_part('year',date)<#{year})" }
      }
    end
  end

  def later_entries
    CashBook.scoped.where(['date > ?', self.date]).where(:workshop => self.workshop)
  end

  attr_accessor :balance

  def balance
    @balance || 0
  end

  def tax
    self.amount / (100 + self.tax_rate) * self.tax_rate
  end

  def amount= am
    unless am.is_a? Numeric or am.nil? or am.empty?
      am.gsub! /[^\d,]+/,''
      am.tr! ',','.'
    end
    write_attribute(:amount, am)
  end


  def before_validation_fürn_arsch
    logger.info "self.amount: #{self.amount.to_s}"
    unless self.amount.nil? or self.amount.empty?
      self.amount.gsub! /[^\d.,]+/,''
      self.amount.tr! ',.','.,'
      self.amount.gsub! ',',''
    end
  end

end
