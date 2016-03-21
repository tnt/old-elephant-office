# coding: utf-8
class EmailAttachment < ActiveRecord::Base
  attr_accessible :email_id, :file_name, :kind, :document_id, :position, :image, :dimensions, :file_size, :alternate_part, :content_id, :inline
  include MyMimes
  belongs_to :email, :touch => true, :autosave => true
  delegate :editable?, :document_updated, :to => :email
  #belongs_to :paper
  belongs_to :document
  acts_as_list :scope => :email_id
  scope :images, :conditions => {:image => true}
  scope :inline_images, :conditions => {:image => true, :inline => true}
  #scope :files, :conditions => ['(inline=false AND alternate_part=false)']
  scope :files, :conditions => {:inline => false, :alternate_part =>false}
  scope :html_parts, :conditions => {:alternate_part => true}

  validates_inclusion_of :kind, :in => %w(document file)

  after_save do # gets executed after destroy as well
    #document_updated
  end

  def real_path
    "#{Elph[:attachments_dir]}/#{self.fs_filename}"
  end
  def web_path
    "/mail_attachments/#{self.fs_filename}"
  end
  def icon_path
    "/mail_attachments/100/#{self.fs_filename}"
  end
  def fs_filename
    "#{'%08d'%self.id}-#{self.clean_filename}"
  end
  def clean_filename
    file_name.gsub /[^-_.!#§$(){}?+<>\w ]/, ''
  end
  def filesize
    if self.file_size.nil?
      return ''
    elsif self.file_size > 800000
      return "%0.1fMB" % (self.file_size / (1024.0*1024))
    elsif self.file_size > 800
      return "%0.1fkB" % (self.file_size / 1024.0)
    end
    "#{self.file_size.to_s}Byte"
  end
  def content_type
    if self.kind == 'document'
      if self.document.type == 'Paper'
        'application/pdf'
      elsif self.document.type == 'ExternalPaper'
        ext = self.document.foile_name[/[^.]+$/]
        FILE_EXT_TO_MIME_TYPE[ext]
      end
    else #coming verry verry soone
    end
  end
end
