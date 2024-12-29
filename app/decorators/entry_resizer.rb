# frozen_string_literal: true

class EntryResizer
  def self.resize_and_convert_image(image_data, mime_type, width, height)
    format = 'webp'
    tempfile = create_tempfile(image_data, format)

    begin
      image_processor = ImageProcessing::MiniMagick
                        .source(tempfile.path)
                        .strip
                        .resize_to_fit(width, height)
                        .convert(format)

      image_processor = image_processor.quality(95) unless ['image/heic', 'image/heif',
                                                            'application/octet-stream'].include?(mime_type)

      resized_image = image_processor.call

      File.binread(resized_image.path)
    ensure
      tempfile.close!
      tempfile.unlink
    end
  end

  def self.mime_type_to_format(mime_type)
    case mime_type
    when 'image/jpeg', 'image/jpg', 'image/heic', 'image/heif' then 'jpg'
    when 'image/png'                                           then 'png'
    when 'image/webp'                                          then 'webp'
    else
      Rails.logger.warn "対応していないMIMEタイプです: #{mime_type}"
      nil
    end
  end

  private_class_method :mime_type_to_format

  def self.create_tempfile(image_data, format)
    tempfile = Tempfile.new(['image', ".#{format}"])
    tempfile.binmode
    tempfile.write(image_data.read)
    tempfile.rewind
    tempfile
  end

  private_class_method :create_tempfile
end
