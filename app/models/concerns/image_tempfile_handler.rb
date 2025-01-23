# frozen_string_literal: true

module ImageTempfileHandler
  extend ActiveSupport::Concern

  class_methods do
    def create_tempfile(image_data, format)
      tempfile = Tempfile.new(['image', ".#{format}"])
      tempfile.binmode
      tempfile.write(image_data.read)
      tempfile.rewind
      tempfile
    end

    def mime_type_to_format(mime_type)
      case mime_type
      when 'image/jpeg', 'image/jpg', 'image/heic', 'image/heif' then 'jpg'
      when 'image/png'                                           then 'png'
      when 'image/webp'                                          then 'webp'
      else
        Rails.logger.warn "対応していないMIMEタイプです: #{mime_type}"
        nil
      end
    end
  end
end
