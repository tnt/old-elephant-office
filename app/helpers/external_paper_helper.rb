module ExternalPaperHelper
  def get_link ext_p
    title = ext_p.displayable? ? 'Show' : 'Download'
    cls = ext_p.displayable? ? 'show' : 'download'
    target = ext_p.displayable? ? '_pdf_' : nil
    link_to ext_p.file_name_ext, ext_p.file_url, :target => target, :title => title, :class => "#{cls} icon_link"
  end
end
