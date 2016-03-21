# coding: utf-8
class User < ActiveRecord::Base
  validates_confirmation_of :password
  validates_uniqueness_of :username
  
  validate :on => :create do
    errors.add(:password, :blank) if self.password.blank?
  end

  scope :normal_users, :conditions => { :system => false }

  before_save do
    self.password = self.password.blank? ? self.password_was : md5(self.password)
  end

  def signing
    "#{self.gname} #{self.name}"
  end
  
  def md5(pass) # not DRY
    Digest::MD5.hexdigest("--salz--#{pass}")
  end
end
