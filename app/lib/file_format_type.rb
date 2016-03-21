# coding: utf-8

module FileFormatType

  TYPES_TO_EXTENSIONS = {
    image: %w(jpg gif jpeg png bmp),
    pdf: %w(pdf),
    doc: %w(doc docx),
    unknown: [nil]
  }

  EXTENSIONS_TO_TYPE = Hash[TYPES_TO_EXTENSIONS.map {|k,v| v.map {|i| [i, k.to_s]}}.flatten(1)]

  def ff_type
    logger.info "file_name_extension #{file_name_extension}"
    EXTENSIONS_TO_TYPE[file_name_extension]
  end

private

  def file_name_extension
    foile_name.sub(/^.+\.(?=[^.]+$)/, '').downcase if foile_name
  end
end
