module FirePhruby
  HEADERS = {} 
  def self.included(controller)
    controller.after_filter :firephruby_filter
    controller.helper_method :fire_log, :fire_info, :fire_warn, :fire_error, :fire_options
    def controller.fire_options opts; FirePhruby.options = opts; end # this could hopefully be done more elegant
   logger.info 'shiT! am KackAhhhschsch'
  end
  def self.options= opts
    @options ||= {}
    @options.merge! opts
  end
  def self.options
    @options || {}
  end

  def self.logger
    @logger ||= Logger.new Rails.root.to_s + '/log/firephruby_test.log' #ActionController::Base.logger
  end

  FPHR_FUNCTION_NAMES = %w(LOG INFO WARN ERROR)
  FPHR_INIT_HEADERS = { 'X-Wf-Protocol-1' => 'http://meta.wildfirehq.org/Protocol/JsonStream/0.2',
                'X-Wf-1-Plugin-1' =>'http://meta.firephp.org/Wildfire/Plugin/FirePHP/Library-FirePHPCore/0.2.0'}
  FPHR_INIT_HEADERS_LOG = { 'X-Wf-1-Structure-1' => 'http://meta.firephp.org/Wildfire/Structure/FirePHP/FirebugConsole/0.1' }
  FPHR_INIT_HEADERS_DUMP = { 'X-Wf-1-Structure-2' => 'http://meta.firephp.org/Wildfire/Structure/FirePHP/Dump/0.1' }
  FPHR_KINDS = %w(LOG INFO WARN ERROR DUMP TRACE EXCEPTION TABLE)
  FPHR_LEGACY_WARNING = { 'X-FirePHP-Data-100000000001' => '{' ,
          'X-FirePHP-Data-300000000001' => '"FirePHP.Firebug.Console":[',
          'X-FirePHP-Data-300000000002' => '[ "INFO", "This version of FirePHP is no longer supported by FirePHRuby. Please update to 0.2.1 or higher." ],',
          'X-FirePHP-Data-399999999999' => '["__SKIP__"]],',
          'X-FirePHP-Data-999999999999' => '"__SKIP__":"__SKIP__"}' }
  MAX_LENGTH = 4000
  
  protected
  def fire_clog msg,kind='LOG', label=nil
    @firephruby ||= {}
    t_pref,g_kind = kind == 'DUMP' ? [ 2, 'DUMP' ] : [ 1, 'LOG' ]
    # called from a template, the info is in caller[3], from a controller the info is in caller[1]
    file, line, function = caller.find {|l| l.match(/^\(eval\):/).nil? }.split(':') 
    msg_meta = { 'Type' => kind, 'File' => "'#{file}'", 'Line' => line }
    msg_meta['Label'] = label if label
    @fire_msg_index = 0 unless instance_variables.member? :@fire_msg_index
    msg = _firephruby_mask_ruby_types( Marshal.load(Marshal.dump(msg)) ) if ( FirePhruby.options.has_key?(:mask_ruby_types) && FirePhruby.options[:mask_ruby_types] )
    msg = kind == 'DUMP' ? "{#{label.to_json}:#{msg.to_json}}" : "[#{msg_meta.to_json},#{msg.to_json}]"
    (msg.gsub /.{#{MAX_LENGTH}}/ do |m| "#{m}\n" end).split( "\n" ).each_with_index do |msg_part,ind|
      @fire_msg_index += 1
      @firephruby[ "X-Wf-1-#{t_pref}-1-#{@fire_msg_index}"] = "#{msg.size if ind == 0}|#{msg_part}|#{'\\' if ind < msg.size/MAX_LENGTH}" # int/int = int
      #FirePHRuby::HEADERS[ "X-Wf-1-#{t_pref}-1-#{@fire_msg_index}"] = "#{msg.size if ind == 0}|#{msg_part}|#{'\\' if ind < msg.size/MAX_LENGTH}" # int/int = int
      #logger.info "####--- #{@firephruby.size} @fire_msg_index: #{@fire_msg_index} instancevari:#{instance_variables.sort.join(' - ')}"
    end
    unless instance_variables.member? "@firephruby_inited_#{g_kind.downcase}".to_sym
      @firephruby.merge! FirePhruby::const_get( "FPHR_INIT_HEADERS_#{g_kind}" )
      #logger.info '---------------'
      instance_variable_set( "@firephruby_inited_#{g_kind.downcase}".to_sym, true )
    end
  end
  def fire_options options={}
    FirePhruby.options = options
  end
  FPHR_FUNCTION_NAMES.each { |x| self.module_eval "def fire_#{x.downcase} msg, label=nil; fire_clog msg,'#{x}',label; end" }
  def fire_dump obj, label=''
    fire_clog obj,'DUMP', label
  end

  private
  def _firephruby_initialize_request ua
    opts = FirePhruby.options
    @firephp_version = ua.match( /FirePHP\/(\d+)\.(\d+)(?:\.([\db.]+))?/)
    @firephp_version = @firephp_version[1,3].map {|i| i.to_i} if @firephp_version
    firephp_01_version = ( @firephp_version || [0,2] )[0,2].join('.').to_f<0.2 
    #@firephpruby_skip = @firephp_version.nil? || firephp_01_version
    @firephruby.merge! firephp_01_version ? FPHR_LEGACY_WARNING : FPHR_INIT_HEADERS
    @firephruby['X-FirePHP-RendererURL'] = opts[:renderer_url] if opts.has_key? :renderer_url
    @firephruby['X-FirePHP-ProcessorURL'] = opts[:processor_url] if opts.has_key? :processor_url
  end
  def firephruby_internal_log msg
    @fire_msg_index ||= 0 
    @fire_msg_index += 1
    msg = "[#{{:Type=>'LOG',:Label=>'____________________________ internal message'}.to_json},#{msg.to_json}]"
    @firephruby["X-Wf-1-1-1-#{@fire_msg_index}"] = "#{msg.size}|#{msg}|"
  end
  def _firephruby_mask_ruby_types data, skip=true # skip masking if not hash key
    if data.is_a? String
      return data
    elsif data.is_a? Integer
      return "__INT__#{data.to_s}__INT__"
    elsif data.is_a? Numeric
      return skip ? data : "__NUM__#{data.to_s}__NUM__"
    elsif data.is_a? TrueClass or data.is_a? FalseClass
      return skip ? data : "__BOOL__#{data.to_s}__BOOL__"
    elsif data.nil?
      return skip ? data : '__NIL__nil__NIL__'
    elsif data.is_a? Symbol
      return "__SYM__:#{data.to_s}__SYM__"
    elsif data.is_a? Array
      #firephruby_internal_log 'wird'
      return data.map { |v| _firephruby_mask_ruby_types v }
    elsif data.is_a? Hash
      k_types = [ Symbol, Fixnum, Bignum, Float, Range, TrueClass, FalseClass, NilClass ]
      j_types = [ Array, Hash ]
      data.each { |k,v| data[k] = _firephruby_mask_ruby_types v }
      keys_to_mask = data.keys.select { |k| k_types.include? k.class }
      keys_to_mask.each { |k| nk = _firephruby_mask_ruby_types k,false; data[nk] = data[k]; data.delete k }
      keys_to_jsonize = data.keys.select { |k| j_types.include? k.class }
      keys_to_jsonize.each do |k| 
        nk = _firephruby_mask_ruby_types( k,false ).to_json 
        data["__JSON__#{nk}__JSON__"] = data[k]
        data.delete k
      end
      return data
    elsif data.is_a? Range
      return "__RNG__#{data.to_s}__RNG__"
    end
    #firephruby_internal_log 'shit happens - class: ' + data.class.to_s
    return data.to_s
  end
  def firephruby_filter
    logger.info '____________________  einsc  _________________________'
    @firephruby ||= {}
    # Add headers only when browser has FirePHP-Plugin
    #return if !(request.headers["HTTP_USER_AGENT"]=~/FirePHP\//)
    # Do not add headers in production mode
    return if ENV["RAILS_ENV"] == "production"
    return if @firephruby.empty?
    
    _firephruby_initialize_request( request.headers["HTTP_USER_AGENT"] )
    
    return if @firephpruby_skip
    
    #@S.each_pair { |k,v| headers[k] = v }
    @firephruby.each_pair { |k,v| response.headers[k] = v }
    #logger.info @firephruby.inspect
  end
end
