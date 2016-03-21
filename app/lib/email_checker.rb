# coding: utf-8
class EmailChecker
  include MyMimes
  #include Constants
  #include IMAPConf
  include ElphConfig

  imap_settings = Elph[:imap_settings]
  
  def self.test_it 
    "Hitta really, really borkse!"
  end
  
  def self.logger
    @logger ||= Logger.new Rails.root.to_s + '/log/test_mail_checker.log' #ActionController::Base.logger
  end
  
  def self.logger= logger
    @logger = logger # for setting it from daemon script
  end
  
  def self.reset_uids_of_outgone_emails
      imap = Net::IMAP.new(imap_settings[:host])
      imap.authenticate('LOGIN', imap_settings[:user_name], imap_settings[:password])
      imap.examine(imap_settings[:folders][:sent])
      logger.info "______________________ resetting uids for outgone emails _____________________"
      Email.outgone_emails.each do |email|
        if email.message_id.nil? || email.message_id.empty?
          logger.warn "  EMPTY MESSAGE-ID  email <#{email.id}> uid '#{email.imap_uid || 'UNDEFINED'}'" 
          next
        end
        uid = imap.uid_search(['HEADER','Message-Id',email.message_id])[0]
        next if uid.nil? or [email.imap_uid, email.imap_server] == [uid, imap_settings[:imap_server]]
        email.update_attributes({:imap_uid => uid, :imap_server => imap_settings[:imap_server]})
        logger.info "  email <#{email.id}> uid '#{email.imap_uid || 'UNDEFINED'}' #{email.message_id}"
      end
      imap.disconnect
  end
  
  def self.check_for_externally_sent_emails
      imap = Net::IMAP.new(imap_settings[:host])
      imap.authenticate('LOGIN', imap_settings[:user_name], imap_settings[:password])
      imap.examine(imap_settings[:folders][:sent])
      imap.disconnect
  end
  
  def self.check_mails s_options={}
    options = {
      :is_foreign => true,
      :re_read_all => false,
      :user_id => User.find_by_username('mdaemon').id,
      :since => 1
    }
    options.merge! s_options
    mailbox = options[:is_foreign] ? :inbox : :sent
    logger.info "   ----------- begin checking emails... ---------------------"
    #begin
      imap = Net::IMAP.new(imap_settings[:host])
      imap.authenticate('LOGIN', imap_settings[:user_name], imap_settings[:password])
      imap.select(imap_settings[:folders][mailbox])
      gestern = (Date.today - options[:since]).strftime( '%d-%b-%Y')
      new_emails = []
      last_emails = imap.uid_search(['SINCE', gestern])
      logger.info "   ----------- last_emails: #{last_emails.inspect} ---------------------"
      last_emails -= Email.where(:imap_uid => last_emails, :imap_server => imap_settings[:imap_server], 
        :is_foreign => options[:is_foreign]).map {|e| e.imap_uid} unless options[:re_read_all]
      logger.info "   ----------- last_emails: #{last_emails.inspect} reloaded ---------------------"
      last_emails.each do |message_uid|
        logger.info "   ----------- Email message_uid: #{message_uid} ---------------------"
        @email = Email.find_or_create_by_imap_uid_and_imap_server_and_is_foreign message_uid, imap_settings[:imap_server], options[:is_foreign]
        next if @email.persisted? and ( options[:re_read_all] === false || @email.self_generated_email )
        #begin
          mo =  Mail.new(imap.uid_fetch(message_uid, 'BODY.PEEK[]')[0].attr['BODY[]'])
          #mo =  Mail.new(imap.uid_fetch(message_uid, 'RFC822')[0].attr['RFC822'])
          contact_address, contact_name = options[:is_foreign] ? 
            [mo.from[0],mo[:from].decoded] : 
            [mo.to[0],mo[:to].decoded]
          email_contact = EmailAddress.where('email_address_specifics.email' => contact_address, :outdated => false).first
          unless email_contact
            name = contact_name.to_s.sub /["']?(.+?)["']?\s*<.+@.+>$/, '\1'
            email_contact = EmailAddress.create(:name => name, :customer_id => imap_settings[:un_assigned_customer_id], 
                  :sex => 'neutral', :specific_attributes => {:email => contact_address})
          end
          email_contact.emails << @email
          logger.info "  soweit message_uid: #{message_uid} ---------------------"
          #if em_add.length > 1
          #	fire_log 'mutiple instances of EmailAddress ' + mo.from
          #	em_add.reject! {|em| em.contactable.outdated if em.contactable}
          #end
          #fire_log "#{mo[:from]}: \t#{mo.subject} - #{mo.multipart? ? mo.parts.length : (mo.parts ? mo.parts.length : 'nischni' )}"
          @email.attributes = { :message_id => mo[:message_id].to_s, :in_reply_to => mo[:in_reply_to].to_s, 
            :references => mo[:references].to_s, :is_foreign => options[:is_foreign], :imap_uid => message_uid, 
            :date => mo.date, :subject => mo.subject, :user_id => options[:user_id], :last_modified_by => options[:user_id] }
          @email.attributes = {:seen => false} unless ! options[:is_foreign] || @email.persisted?
          @email.attributes = {:sent => true} unless options[:is_foreign]
          @email.save
          logger.info "  Processing message with uid: #{message_uid} ---------------------"
          @email.update_attribute :message,  process_mail(mo)
          new_emails << @email
          #imap.copy(message_id, "INBOX.recorded")
        #rescue Exception => exc
          logger.info "  soweit message_uid: #{message_uid} ---------------------"
          #imap.copy(message_id, "INBOX.unprocessable")
          #fire_log exc, "TMail-Fehler (wahrscheinlich) #{exc.backtrace[0]}"
        #end
        #imap.store(message_id, "+FLAGS", [:Deleted])
      end
      #imap.expunge
      imap.disconnect
    #rescue Net::IMAP::NoResponseError => exc
    #	fire_log exc, 'NoResponseError'
    #rescue Net::IMAP::ByeResponseError => exc
    #	fire_log exc, 'ByeResponseError'
    #rescue => exc
    #	fire_log exc, 'IMAP-Fehler (wahrscheinlich)'
    #end
    #fire_log 'Öhhhhhhhh'

  
    new_emails
  end

  protected
  
  def self.save_html_part html
    @html_part_counter += 1
    file_name = "html_part_#{@html_part_counter}.html"
    att_record = @email.attachments.find_or_create_by_file_name file_name
    unless att_record.persisted?
      att_record.kind = 'file'
      att_record.alternate_part = true
      att_record.save
    end
    http_equiv_header = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
    # Microsoft HTML-mails somtimes have unquoted attribute values  
    html.sub!(/<meta[^>]+http-equiv=(["']?)Content-Type\1[^>]*>/i, http_equiv_header) || html.sub!(/<\/head/i, http_equiv_header+"\n</head")
    unless html =~ /<\/body>/i
      html = "<html>\n<head>\n<title>#{@email.subject}</title>\n#{http_equiv_header}</head>\n<body>\n#{html}</body>\n</html>"
    end
    fh = File.open(att_record.real_path, 'wb')
    fh.puts html
    fh.close
    att_record.update_attribute :file_size, File.size(att_record.real_path)
  end
  
  def self.get_text_from_part part
    convert2utf8(part.decoded, (part.charset || part[:content_type].charset))
  end
  
  def self.process_mail mail, depth=0
    logger.info "  Processing mail: #{mail['Message-Id']} ---------------------"
    @attachment_counter, @html_part_counter = [0, 0] if depth === 0
    depth += 1
    text_content = ''
    text_found = false
    if mail.multipart?
      if mail.text_part
        text_content += get_text_from_part mail.text_part
        text_found = true
      end
      if mail.html_part
        html = get_text_from_part mail.html_part
        save_html_part html
        text_content += strip_html(html) unless text_found
      end
    elsif mail[:content_type].content_type === 'text/plain'
      text_content += convert2utf8 mail.body.decoded, mail.charset
    elsif mail[:content_type].content_type === 'text/html'
      html = convert2utf8(mail.body.decoded, mail.charset)
      save_html_part html
      text_content += strip_html(html)
    end
    mail.attachments.each do |att|
      @attachment_counter += 1
      file_name = att.filename || "namenlos_#{@attachment_counter}.#{MIME_TYPE_TO_FILE_EXT[att[:content_type].content_type]}"
      att_record = @email.attachments.find_or_create_by_file_name file_name
      unless att_record.persisted?
        att_record.kind = 'file'
        att_record.save
      end
      fh = File.open(att_record.real_path, 'wb')
      fh.puts att.body.decoded
      fh.close
      att_record.content_id = att.content_id.to_s.sub(/^<(.*)>$/, '\1') if att.content_id
      att_record.inline = true if att.content_disposition && att.content_disposition.downcase === 'inline'
      att_record.file_size = File.size(att_record.real_path)
      att_record.save
      if att[:content_type] && att[:content_type].content_type == 'message/rfc822'
        mo =  Mail.new(att.body.decoded)
        text_content += "\r\n#{'_'*40}\r\n Angehängte Nachricht von #{mo[:from]} vom #{mo.date.strftime '%d.%m.%Y %H:%M:%S'}\r\n Betreff: #{mo.subject}"
        text_content += "\r\n\r\n#{process_mail(mo, depth)}"
      elsif att[:content_type] && att[:content_type].content_type.downcase.include?('image')
        ImageScience.with_image(att_record.real_path) do |img|
          att_record.update_attributes(:image => true, :dimensions => "#{img.width}x#{img.height}")
          extent = [img.width,img.height].max
          [100, 400, 800].each do |size|
            target = "#{ATTACHMENTS_DIR}/#{size.to_s}/#{att_record.fs_filename}"
            if size < extent
              img.thumbnail(size) {|t| t.save target}
            else
              FileUtils.copy att_record.real_path, target
            end
          end
        end
      end
    end
    if depth === 1 and @email.attachments.html_parts.size > 0 and @email.attachments.inline_images.size > 0
      @email.attachments.html_parts.each do |html_part|
        html = File.read html_part.real_path
        @email.attachments.inline_images.each do |img|
          next unless img.content_id
          html.gsub! /(<img.+?src=["'])cid:#{img.content_id}(['"])/, "\\1#{img.fs_filename}\\2"
        end
        save_file html_part.real_path, html
      end
    end
    return text_content
  end

  def self.save_file file_path, content
    fh = File.open(file_path, 'wb')
    fh.puts content
    fh.close
  end

  def self.strip_html html
    html.sub!(/<head>.*<\/head>/m, '')
    html.gsub!(/(?:\s+|(?:&nbsp;)+)/, ' ')
    html.gsub!(/<a[^>]*?href=["'](http:[^"']+)["'][^>]*>([^<]*)<\/a>/, '\2:\1')
    html.gsub!(/<a[^>]*?href=["']mailto:([^"']+)["'][^>]*>([^<]*)<\/a>/, '\1')
    html.gsub!(/<p>\s*/, "\n\n" )
    html.gsub!(/<\/div>\s*/, "\n\n" )
    html.gsub!(/<br ?\/?>\s*/, "\n" )
    html.gsub!(/<\/tr>\s*/, "\n" )
    html.gsub!(/\s*<\/td>\s*<td>\s*/, "    " )
    html.gsub!(/<.*?>/, '')
    html.gsub!(/\A\s+|\s+\Z/m, '')
  end

  def self.convert2utf8 str, charset
    logger.info "  --  encoding found: '#{charset}'  -- "
    str.force_encoding charset
  rescue
    logger.info "  --  shitty encoding found: '#{charset}'  -- "
    str.force_encoding('BINARY').gsub!(Regexp.new('[\x00-\x08\x0B\x0C\x0E-\x1F\x80-\xFF]',nil,'n'), '.')
  ensure
    logger.info "  --  codiere String mit Encoding: '#{str.encoding}'  -- "
    str.force_encoding('BINARY').gsub!(Regexp.new('[\x00-\x08\x0B\x0C\x0E-\x1F\x80-\xFF]',nil,'n'), '.') unless str.valid_encoding?
    return str.encode 'UTF-8' # why do I need the exclamation mark?!!!
  end


  def self.process_parts parts, depth=0
    depth += 1
    text_content = ''
    parts.each do |p|
      #fire_log "#{p.content_type}: \t#{p.disposition_param('filename')} #{p.transfer_encoding} - #{p.multipart? ? p.parts.length : 'nischni'}"
      unless p.multipart?
        #body = send("decode_#{p.transfer_encoding.underscore}", body) if p.transfer_encoding && %w(quoted_printable base64).include?(p.transfer_encoding.underscore)
        if p[:content_type].content_type === 'text/plain'   # TEXT_TYPES.include? p[:content_type].content_type
          text_content += convert2utf8 p.body.decoded, p.charset
        elsif p[:content_type].content_type == 'text/html'
          logger.info ' -- message contains HTML-part -----'
          # save the HTML-part in the files directory...
        elsif p[:content_type].content_type == 'message/rfc822'
          mo =  Mail.new(p.decoded)
        elsif p[:content_disposition] && p[:content_disposition].disposition_type == 'attachment'
          @attachment_counter += 1
          file_name = p[:content_disposition].filename || "namenlos_#{@attachment_counter}.#{MIME_TYPE_TO_FILE_EXT[p[:content_type].content_type]}"
          unless @email.attachments.where(:file_name == file_name)
            @email.attachments << EmailAttachment.new({:kind => 'file', :file_name => file_name})
          end
        else
          text_content += "\r\n#{'_'*15} unknown kind of mail part #{'_'*15}\r\n\r\n"
        end
      else
        if mo[:content_type].content_type === 'multipart/alternative'
          text_content += convert2utf8 p.text_part.decoded, p.text_part.charset
        else
          text_content += "\r\n#{'_'*40}\r\n\r\n#{process_parts(p.parts, depth)}"
        end
      end
    end	
    return text_content
  end

end
