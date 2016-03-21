# coding: utf-8
module CashBooksHelper

  include Prawn::Measurements
  include ElphConfig
  include ActionView::Helpers::NumberHelper

  def ordinal cb # OBSOLETE Currently not in use
    "#{cb.date.strftime('%y%m%d%H%M')}#{sprintf('%0.5d',cb.id)}"
  end
  
  def make_pdf2
    
    pdf = Prawn::Document.new(Elph[:pdf_defaults])
    
    pdf.font_families.update(
      "Palatino" => { :bold 		 => "#{Elph[:resdir]}/fonts/Palatino-Bold.ttf",
                :italic      => "#{Elph[:resdir]}/fonts/Palatino-Italic.ttf",
                :bold_italic => "#{Elph[:resdir]}/fonts/Palatino-BoldItalic.ttf",
                :normal      => "#{Elph[:resdir]}/fonts/Palatino.ttf" },
    "Palatino-L" => { :bold 		 => "#{Elph[:resdir]}/fonts/Palatino-Linotype-Bold.ttf",
                :italic      => "#{Elph[:resdir]}/fonts/Palatino-Linotype-Italic.ttf",
                :bold_italic => "#{Elph[:resdir]}/fonts/Palatino-Linotype-BoldItalic.ttf",
                :normal      => "#{Elph[:resdir]}/fonts/Palatino-Linotype.ttf" },
      "Antiqua" => { :bold 		 => "#{Elph[:resdir]}/fonts/Book-Antiqua-Bold.ttf",
                :italic      => "#{Elph[:resdir]}/fonts/Book-Antiqua-Italic.ttf",
                :bold_italic => "#{Elph[:resdir]}/fonts/Book-Antiqua-BoldItalic.ttf",
                :normal      => "#{Elph[:resdir]}/fonts/Book-Antiqua.ttf" },
      'Bodoni' => { :normal      => "#{Elph[:resdir]}/fonts/BodoniStd.ttf",
                :book			=> "#{Elph[:resdir]}/fonts/BodoniStd-Book.ttf" },
      'Garamond' => { :normal      => "#{Elph[:resdir]}/fonts/GaramondPremrPro.ttf" }
    )
    
    line_width = 0.3
    pdf.line_width = line_width
    
    pdf.canvas do

#			pdf.font 'Palatino', :size => 11

      [543,421,247].each do |y|
        pdf.horizontal_line 0,22, :at => y
        pdf.stroke
      end
    end
    
    bread_font = "Helvetica"
    pdf.font bread_font, :size => 10
    #bread_font = "Times-Roman"
    #pdf.font bread_font, :size => 11
    #page_number = 1
    
    pdf.draw_text "#{german_date Date.today}", :at => [20,715] #\\003\\207 \\040\\254
    pdf.move_down 100

    table_opts = {
      :cell_style => { 
        :borders => [],
        :padding => [ 1, 3, 0, 3 ]
      },
      :column_widths => [ 65, 65, 65, 65 ]
    }

    table_style_proc = Proc.new { columns(0).align = :right; columns(1).align = :right; columns(2).align = :center }

    cb_data = []

    @cash_books.each do |c|
      purpose = c.paper ? "Rechnung #{c.paper.invoice_number_formatted}" : c.purpose
      cb_line = [c.date.strftime('%d.%m.%y'),"#{c.tax_rate.to_i}%",purpose]
      amount = ( c.direction == 'out' ? '-' : '' ) + number_to_currency(c.amount)
      value = c.workshop ? [nil,amount] : [amount,nil]
      # cb_data << value + cb_line
      cb_data << value + cb_line
    end
    pdf.table cb_data, table_opts, &table_style_proc 

    pdf.horizontal_rule
    pdf.stroke
    
    results_data = [
      [number_to_currency(@results[:sale_in]),number_to_currency(@results[:workshop_in]),nil,nil],
      ["-#{number_to_currency(@results[:sale_out])}","-#{number_to_currency(@results[:workshop_out])}",nil,nil],
      [number_to_currency(@results[:total_sale]),number_to_currency(@results[:total_workshop]),number_to_currency(@results[:total]),nil]
    ]

    pdf.table results_data, table_opts, &table_style_proc
    pdf.render
  end # make_pdf

end
