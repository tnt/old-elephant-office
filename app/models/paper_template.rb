# coding: utf-8
class PaperTemplate
  attr_reader :paper, :template, :ref_paper
  include ApplicationHelper
  include ElphConfig
              
  def initialize(paper)
    logger.info '______________________________________________________________'
    @paper = paper
    @template = Paper.find Elph[:doc_templates][paper.kind]
    @ref_paper = nil
    @template_item_proc = Proc.new {|tpl,pap| logger.info "|| protz: #{tpl.text}"}
  rescue ActiveRecord::RecordNotFound
    raise 'TemplateNotFound'
  end
  
  def content_from_template
    copy_from_template
    eval_all_contents
  end
  
  def content_from_template_for_dun ref_paper # needs to be rewritten
    @ref_paper = ref_paper
    @odoc = ref_paper # for legacy templates
    @nth_dun = @odoc.dun_times? + 1
    copy_from_template
    eval_all_contents
  end
  
  def invoice_from_estimate estimate
    @template = estimate
    @template_item_proc = Proc.new {|tpl,pap| pap.text = 'Bitte überweisen Sie den genannten Betrag auf unser unten angegebenes Konto.' }
    copy_from_template
  end
  
  private
  
  def set_different_template paper
    @template = paper
  end
  
  def logger
    @logger ||= Logger.new Rails.root.to_s + "/log/template-#{Rails.env}.log" #ActionController::Base.logger
  end
  
  def template_macros
    @template_macros ||= PaperTemplateMacros.new self
  end
  
  def copy_from_template
    @paper.update_attribute :subject, @template.subject if @paper.subject.blank?
    @paper.update_attribute :tax_rate, @template.tax_rate
    @template.contents.each do |c|
      newc = c.dup
      @template_item_proc.call(c,newc) if c.template_item
      @paper.contents << newc
      if c.kind == 'rblock'
        c.rblock_lines.each do |rbl|
          newc.rblock_lines << rbl.dup
         end
      end
    end
  end
  
  def eval_all_contents
    @paper.update_attribute :subject, eval_content(@paper.subject, 'the subject')
    @paper.contents.each do |c|
      next if c.text.blank?
      c.update_attribute :text, eval_content(c.text, 'text content') if %w(text signing).include? c.kind
      c.update_attribute :signer, @paper.user_id if c.kind == 'signing'
    end
  end
  
  def eval_content content, context=''
    logger.info "|| evaling string: #{content}"
    #eval( %Q("#{content}") ) # this should of course better be replaced by a DSL
    template_macros.instance_eval( %Q("#{content}") ) # this should of course better be replaced by a DSL
  rescue Exception => exc
    logger.info "||  Something went wrong with the template: #{context}\n|| evaled string: #{content}"
    logger.info exc
    #fire_error exc
    return content
  end
end
