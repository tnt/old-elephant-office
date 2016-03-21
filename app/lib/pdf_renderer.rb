# coding: utf-8

class PdfRenderer
  include ElphConfig
  include PapersHelper
  include ActionView::Helpers::TranslationHelper
  include ApplicationHelper
  RES_DIR = "#{Rails.root.to_s}/#{Elph[:resdir]}"
  attr_accessor :pdf, :rec, :opts, :fspaces, :spaces
  def initialize rec, opts
    pdf_opts = opts[:pdf_opts] || {}
    #pdf_opts[:template] = '/root/rails/iv/RPK/Vorlagen/Gutachten-Dr.Hennig.pdf'
    pdf_opts.merge! Elph[:pdf_defaults].symbolize_keys()
    @pdf = Prawn::Document.new(pdf_opts)
    @rec = rec
    @opts = opts
    @fspaces = GlueStretcher.new rec.scale
    @spaces = {}
  end
  def render
    typeset
    pdf.render.encode 'ASCII-8bit'
  end
  def typeset # to be overridden by derived classes
  end
  def logger
    Rails.taciturn_logger
  end
end
