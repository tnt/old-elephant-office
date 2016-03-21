# coding: utf-8

module ToPdf
  include ElphConfig # why??????
  def to_pdf opts={}
    opts[:pdf_opts] ||= {}
    opts[:pdf_opts][:info] = { Author: self.get_signer.signing, Subject: self.subject }
    renderer = Elph[:pdf_renderers][self.class.name.underscore.to_sym][self.kind].camelcase.constantize.new self, opts
    renderer.render 
  end
end
