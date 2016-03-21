# coding: utf-8

class TheloniusPaperDefault < PdfRenderer
  def typeset
    document_kind_specifics = {
      :barrechnung => {
        :heading => 'Rechnung'
      },
      :rechnung => {
        :heading => 'Rechnung'
      },
      :kostenvoranschlag => {
        :heading => 'Kostenvoranschlag'
      },
      :brief => {
        :heading => nil
      },
      :angebot => {
        :heading => 'Angebot'
      },
      :mahnung => {
        :heading => 'Zahlungserinnerung'
      },
      :wertbestätigung => {
        :heading => 'Wertbestätigung'
      }
    }
    tax_rate_str = rec.tax_rate.to_s.sub(/\.(\d+)$/,',\1').sub(',0','')
    c_results_labels = {:sum => 'Summe', :tax => "#{tax_rate_str}% Mehrwertsteuer", :total => 'Gesamt'}
    dksp = document_kind_specifics[rec.kind.to_sym]
    pdf.font_families.update(
      "Palatino" => { :bold 		   => "#{RES_DIR}/fonts/Palatino-Bold.ttf",
                      :italic      => "#{RES_DIR}/fonts/Palatino-Italic.ttf",
                      :bold_italic => "#{RES_DIR}/fonts/Palatino-BoldItalic.ttf",
                      :normal      => "#{RES_DIR}/fonts/Palatino.ttf" },
    "Palatino-L" => { :bold 		   => "#{RES_DIR}/fonts/Palatino-Linotype-Bold.ttf",
                      :italic      => "#{RES_DIR}/fonts/Palatino-Linotype-Italic.ttf",
                      :bold_italic => "#{RES_DIR}/fonts/Palatino-Linotype-BoldItalic.ttf",
                      :normal      => "#{RES_DIR}/fonts/Palatino-Linotype.ttf" },
       "Antiqua" => { :bold 		   => "#{RES_DIR}/fonts/Book-Antiqua-Bold.ttf",
                      :italic      => "#{RES_DIR}/fonts/Book-Antiqua-Italic.ttf",
                      :bold_italic => "#{RES_DIR}/fonts/Book-Antiqua-BoldItalic.ttf",
                      :normal      => "#{RES_DIR}/fonts/Book-Antiqua.ttf" },
        'Bodoni' => { :normal      => "#{RES_DIR}/fonts/BodoniStd.ttf",
                      :book		  	 => "#{RES_DIR}/fonts/BodoniStd-Book.ttf" },
      'Garamond' => { :normal      => "#{RES_DIR}/fonts/GaramondPremrPro.ttf" }
    )

    fspaces.update  :paragraph_after => [3,6,14],
                    :leading => [-0.5,1,5],
                    :o_subject_before => [15,25,35], # -
                    :o_subject_after  => [25,35,45], #  \  prefix o = only
                    :o_heading_before => [20,60,80], #   |        b = both
                    :o_heading_after  => [20,40,60], #   |
                    :b_subject_before => [10,25,40], #   |-- subject/heading spaces
                    :b_subject_after  => [16,24,36], #   |
                    :b_heading_before => [10,20,30], #   |
                    :b_heading_after  => [20,32,40], #  /
                    :wether_nor       => [40,60,80], # -
                    :table_vertical_padding => [1,2,4],
                    :table_space_after => [2,6,10],
                    :chop_space_after => [15,20,30],
                    :chop_space => [60,75,90]

    line_width = 0.3
    pdf.line_width = line_width

    pdf.canvas do # here should be all the static positioned stuff (address, docnum etc.)

      lm = Elph[:pdf_defaults][:left_margin]
      strasse, strs, stadt, phone = 'Washingtonallee 7', 'Washingtonallee 7', '01099 Dresden', '0351 / 88 77 66 55'
      pdf.font 'Helvetica', :size => 11
      pdf.text_box "Thelonius Kort\n#{strasse}\n#{stadt}\n#{phone}", :leading => 2, :at => [lm,800]
      pdf.font 'Helvetica', :size => 8
      pdf.draw_text "T. Kort, #{strs}, #{stadt}", :at => [lm,697]
      # pdf.draw_text 'http://kort-basses.com     (+49 30) 61 28 49 41', :at => [342,697]

      pdf.font 'Helvetica', :size => 11
      tabu = 340
      tobb = 770
      c_refs = ""
      %w(cust_ref1 cust_ref2).each do |f|
        c_refs += "#{rec.address.send f}\n" unless rec.address.send(f).blank?
      end
      pdf.text_box c_refs, :leading => 1, :at => [tabu,tobb]

      pdf.draw_text "#{german_date rec.date}", :at => [455, 636]


      # pdf.draw_text 'USt.-Id.: DE-239434048     Steuernummer 14 / 393 / 62510', :at => [185,30]#, :align => :center
      pdf.font 'Helvetica', :size => 9
      pdf.text_box 'comdirect bank AG    IBAN DE21 40530453 04359485    BIC COBADEHDXXX', :at => [0,27], :align => :center

      [543,421,247].each do |y|
        pdf.horizontal_line 0,22, :at => y
        pdf.stroke
      end
    end

    bread_font = "Helvetica"
    pdf.font bread_font, :size => 11
    page_number = 1

    pdf.bounding_box([0,636], :width => 290, :height => 110) do

      pdf.text address_lines(rec.address).join("\n"), :leading => 1
      #pdf.stroke_bounds
    end

    table_opts = {
      :cell_style => {
        :borders => [],
        :padding => [ fspaces[:table_vertical_padding], 0, fspaces[:table_vertical_padding], 0 ]
      },
      :column_widths => [ 410, 70 ]
    }

    table_style_proc = Proc.new { columns(1).align = :right }

    pdf.default_leading fspaces[:leading]

    pdf.draw_text '', :at => [0,538]

    has_subject = ! rec.subject.blank?

    if has_subject
      pdf.move_down dksp[:heading] ? fspaces[:b_subject_before] : fspaces[:o_subject_before]
      pdf.text quote_amp(rec.subject)
      pdf.move_down dksp[:heading] ? fspaces[:b_subject_after] : fspaces[:o_subject_after]
    end

    if dksp[:heading]
      #pdf.default_style.update( :style => :bold )
      pdf.move_down has_subject ? fspaces[:b_heading_before] : fspaces[:o_heading_before]
      #print_stretched pdf, "<b>#{dksp[:heading]}</b>", 5, pdf.cursor
      pdf.text "<b>#{dksp[:heading]}</b>", :character_spacing => 5, :inline_format => true, :align => :center
      #pdf.default_style.update( :style => :normal )
      pdf.move_down has_subject ? fspaces[:b_heading_after] : fspaces[:o_heading_after]
    end

    unless dksp[:heading] or has_subject
      pdf.move_down fspaces[:wether_nor]
    end

#pdf.default_style.update( :leading => 16)

    Rails.taciturn_logger.info "_________________ once again _______________________________\n #{table_opts.inspect}"

    def page_break pdf, fspaces, table_opts, sf, page_number, line_width
      page_number += 1
      pdf.start_new_page :bottom_margin => 20
      fspaces.scale_factor = sf
      table_opts[:cell_style][:padding] = [ fspaces[:table_vertical_padding], 0, fspaces[:table_vertical_padding], 0 ]
      pdf.default_leading fspaces[:leading]
      pdf.line_width = line_width
    end


    rec.contents.each do |c|
      if c.kind == 'text'
        pdf.text c.text_with_indent, :align => :justify
      elsif c.kind == 'signing'
        signer = User.find c.signer

        pdf.move_down fspaces[:chop_space]
        chop_ypos = pdf.cursor + 55 + fspaces[:leading]
        pdf.text quote_amp(c.text)

        # logger.info "pdf.cursor: #{pdf.cursor} - pdf.y: #{pdf.y}"
        chop_file_path = "#{RES_DIR}/bilder/#{signer.username}_tr.png"
        # logger.info " --- #{chop_file_path} existiert: '#{File.exists? chop_file_path}' --pdf.y: '#{pdf.y}', chop_ypos: '#{chop_ypos}'"
        pdf.image chop_file_path, :at => [0, chop_ypos], :height => 55 if opts[:chop] and File.exists? chop_file_path
        pdf.move_down fspaces[:chop_space_after]

      elsif c.kind == 'rblock'
        rb_scale_factors = c.rblock_lines.select {|rbl| rbl.kind == 'pagebreak'}.map {|pb| pb.text.to_f}
        #fire_log 'rb_scale_factors: ' + rb_scale_factors.inspect
        rb_parts = c.rblock_lines.split {|rbl| rbl.kind == 'pagebreak'}
        #fire_log "rb_parts[0].length: '#{rb_parts[0].length}'"
        next if rb_parts[0].length == 0
        rbp_data = []
        rb_parts.each_with_index do |rb_part,rbp_index|
          rb_part.each {|rbl| rbp_data << [ quote_amp(rbl.text), number_to_currency(rbl.price) ]}
          pdf.table rbp_data, table_opts, &table_style_proc
          unless rbp_index + 1 == rb_parts.length
            #pdf.line_width = line_width
            pdf.horizontal_rule
            pdf.stroke
            subtotal = rb_part.inject(0) {|sum,rbl| sum + rbl.price.to_f }
            pdf.table [['Zwischensumme', number_to_currency(subtotal)]], table_opts, &table_style_proc
            page_break pdf, fspaces, table_opts, rb_scale_factors[rbp_index], page_number, line_width
            rbp_data = [['Zwischensumme von vorhergehender Seite', number_to_currency(subtotal)]]
          end
        end
        rb_data = []
        #pdf.line_width = line_width
        pdf.horizontal_rule
        pdf.stroke
        [:sum,:tax,:total].each {|k| rb_data << [ c_results_labels[k], number_to_currency(c.send(k)) ] }
        #rb_data[2][1] = "<b><u>#{rb_data[2][1].sub('€','')}</u></b>&#20AC;"
        rb_data.shift if ( c.rblock_lines.length == 1 ||  rec.tax_rate == 0 )
        rb_data[0] = [ 'Mehrwertsteuer', 'entfällt'] if rec.tax_rate == 0
        pdf.table rb_data, table_opts, &table_style_proc
        totals_width = pdf.font.compute_width_of( number_to_currency(c.total) ).to_f
        pdf.horizontal_line pdf.margin_box.width - totals_width + 6, pdf.margin_box.width + 1, :at => pdf.cursor + fspaces[:table_vertical_padding]
        pdf.horizontal_line pdf.margin_box.width - totals_width + 6, pdf.margin_box.width + 1, :at => pdf.cursor + fspaces[:table_vertical_padding] - 1
        pdf.stroke
        pdf.move_down fspaces[:table_space_after]
      elsif c.kind == 'pagebreak'
        page_break pdf, fspaces, table_opts, c.text.to_f, page_number, line_width
      end
      pdf.move_down fspaces[:paragraph_after]
    end

    if pdf.page_count > 1
      string = "Seite <page> von <total>"
      options = {
        :at => [0, 0],
        :align => :center,
        :page_filter => lambda {|p| p > 1},
        :start_count_at => 2
      }
      pdf.number_pages string, options

      options = {
        :at => [400, 653],
        :page_filter => [ 1 ],
        :start_count_at => 1
      }
      pdf.number_pages '<page> / <total>', options
    end
  end
end
