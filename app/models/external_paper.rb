class ExternalPaper < Document
  include FileFormatType

  attr_accessor :upload

  attr_accessible :realization_from, :realization_to, :address_id, :date, :kind, :subject, :remark, :value, :file

  validates :file, :subject, :presence => true, :on => :create

  before_destroy do |ep|
    File.delete ep.file_path if File.exists? ep.file_path
  end

  def self.save_upload(adp, instanz)
    # Rails.taciturn_logger.info "adp in save_upload: #{adp}"
    instanz.file =  adp.original_filename
    instanz.upload = adp
  end

  after_save do |ep|
    File.open(ep.file_path, "wb") { |f| f.write(ep.upload.read) } if ep.upload
    # Rails.taciturn_logger.info ep.upload
  end

  def foile_name
    self.read_attribute :file
  end

  def to_blob
    File.read(file_path)
  end

  def store_dir
    'external'
  end

  def file_url
    "/#{store_dir}/#{file_prefix}#{file}"
  end

  def file_path
    "#{Rails.root.to_s}/public#{file_url}"
  end

  def file_prefix
    '%0.9d-' % self.id
  end
  
  def file_name_ext
    file.sub(/.+\.(?=[^.]+)/, '')
  end
  
  def displayable?
    Elph['displayable_formats'].include? file_name_ext
  end
  # def cfile_url
  #   file_url
  # end
end
