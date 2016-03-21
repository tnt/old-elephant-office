# coding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::NumberHelper

  def data_button(caption, data_args, html_args={})
    # atts = [data_args, html_args].map {|h|}
    d_atts = data_args.map  {|k,v| "data-#{k.to_s}=\"#{v.to_s}\""}.join(" ")
    h_atts = html_args.map  {|k,v| "#{k.to_s}=\"#{v.to_s}\""}.join(" ")
    "<button #{d_atts} #{h_atts}>#{caption}</button>"
  end

  def number_to_currency_unused(number, options = {})
    options[:locale] ||= I18n.locale
    super(number, options)
  end
  module_function :number_to_currency

  def kaminari_url_fix url
    #logger.info "---------------------- URL: #{url} ---------------------"
    url = (url =~ /[?&]page=\d+/) ? url : ( url.include?('?') ? url.sub('?', '?page=1&') : "#{url}?page=1" )
    #logger.info "---------------------- URL: #{url} ---------------------"
    url
  end

  def rs_link_to *args, &block
    if block_given?
      url_options      = args.first || {}
      args << url_options unless args.first
      html_options = args.second || {}
      args << html_options unless args.second
    else
      url_options      = args.second || {}
      args << url_options unless args.second
      html_options = args.third || {}
      args << html_options unless args.third
    end
    unless html_options[:skip_rs]
      if url_options.is_a?(Hash)
        url_options.merge!(:format => :jsonrs)
      elsif  url_options.is_a?(String) # This is bullshit
        url_options = "#{url_options.to_s}.jsonrs"
      elsif url_options.respond_to? :model_name # This also
        url_options = "/#{url_options.model_name.underscore.pluralize}/#{url_options.id}.jsonrs"
      end
      html_options.merge! :remote => true, 'data-room-service' => true
    end
    link_to(*args, &block)
  end

  def rs_form_tag *args, &block
    url_options      = args.first || {}
    args << url_options unless args.first
    html_options = args.second || {}
    args << html_options unless args.second
    url_options.is_a?(String) ? url_options.concat('.jsonrs') : url_options.merge!(:format => :jsonrs)
    html_options.merge! :remote => true, 'data-room-service' => true
    form_tag(*args, &block)
  end

  def rs_form_for *args, &block
    options =  args.second || {}
    url_options   = options[:url] || {}
    options[:url] = url_options unless options[:url]
    html_options = options[:html] || {}
    options[:html] = html_options unless options[:html]
    url_options.is_a?(String) ? url_options.concat('.jsonrs') : url_options.merge!(:format => :jsonrs)
    html_options.merge! 'data-room-service' => true
    options[:remote] = true
    form_for(*args, &block)
  end


  def datetime_local_field_tag name, date, options={} # the new HTML5 datetime input
    text_field_tag name, date.strftime('%Y-%m-%dT%H:%M:%S'), {:type => 'datetime-local'}.merge(options)
  end

  def strip_rr file
    file.sub Rails.root.to_s, ''
  end

  def german_date date
    date.strftime('%d.%m.%Y') #.gsub /0(\d\.)/, '\1'
  end

  def german_date_time date
    date.strftime('%d.%m.%y %H:%M') #.gsub /0(\d\.)/, '\1'
  end

  def navi_item *args, &block
     if block_given?
      args[0]	||= {}
      args[1]	||= {}
      options      = args.first
      html_options = args.second
    else
      args[1]	||= {}
      args[2]	||= {}
      options      = args.second
      html_options = args.third
    end
    #options.merge! :_rand_ => 1
    #html_options[:class] = (current_page?(options) ? html_options[:class][0] : html_options[:class][1]) if html_options[:class].class.to_s == 'Array'
    classe = current_page?(options) ? 'active' : ''
    "<li class='#{classe}'>#{link_to(*args, &block)}</li>".html_safe
  end

  # def ajax_slider record, opts
    # model_name = record.class.to_s.underscore
    # slider_id = "#{model_name}_#{record.id}_scale_slider"
    # url_opts = {} # is fusch
    # [:controller,:action].each {|k| url_opts[k] = opts[k]}
    # html = <<HTML
    # <div id="#{slider_id}" class="slider">
        # <div class="handle">
        # <div></div>
        # </div>
      # </div>
      # <!-- <p id="test_teil">#{model_name} #{url_for url_opts } </p>-->
#
# HTML
    # js = javascript_tag <<JSEND
    # (function() {
     # var slider_el = $('#{slider_id}');
     # var test_teil = $('test_teil');
#
     # new Control.Slider(slider_el.down('.handle'), slider_el, {
      # minimum: 0,
      # maximum: 1,
      # sliderValue: #{record.send(opts[:field_name])},
      # onChange: function(value) {
        # //test_teil.innerHTML = value;
        # new Ajax.Request('#{url_for url_opts }/#{record.id}',
          # {asynchronous:true, evalScripts:true,
          # parameters:{authenticity_token:'#{form_authenticity_token()}','#{model_name}[#{opts[:field_name]}]':value},
          # onLoading: function(){slider_el.addClassName('loading');},
          # onSuccess: function(){slider_el.removeClassName('loading');}}
        # );
      # }
     # });
    # })();
#
# JSEND
# (html + js).html_safe
  # end

  def select_page_options page
    #fire_log page
    rstr = ''
    %w(10 15 20 25 30 35 40 45 50).each do |c|
      rstr += "<option value='#{c}'#{c==page ? ' selected=\'selected\'':''}"
      rstr += ">#{c} pro Seite</option>"
    end
    rstr.html_safe
  end

  def link_to_random(*args, &block)
     if block_given?
      url = args.first || {}
      args << url unless args.first
      html_options = args.second || {}
      args << html_options unless args.second
    else
      url = args.second || {}
      args << url unless args.second
      html_options = args.third || {}
      args << html_options unless args.third
    end
    url.is_a?(String) ? url.sub!(/\?|\b$/,'?_rand_=1&') : url.merge!(:_rand_ => 1)
    html_options.merge! :onclick => 'this.href = this.href.replace(/_rand_=[\d.]+/,&quot;_rand_=&quot;+Math.random())'.html_safe
    # html_options.merge! 'data-scalable' => 'false' unless html_options.has_key? 'data-scalable'
    link_to(*args, &block)
  end

  def tct_logger
    Rails.taciturn_logger
  end
end
