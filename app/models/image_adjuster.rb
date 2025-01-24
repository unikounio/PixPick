# frozen_string_literal: true

class ImageAdjuster
  def initialize(image_data, mime_type)
    @image_data = image_data
    @mime_type = mime_type
  end

  def resize_and_convert_image(width:, height:)
    format = mime_type_to_format || 'webp'
    tempfile = create_tempfile(format)

    begin
      image_processor = ImageProcessing::Vips
                        .source(tempfile.path)
                        .saver(strip: true)
                        .resize_to_fit(width, height)

      if %w[image/heic image/heif application/octet-stream].include?(@mime_type)
        content_type = @mime_type
      else
        image_processor = image_processor.saver(format: 'webp', quality: 90)
        content_type = 'image/webp'
      end

      resized_image = image_processor.call

      [File.binread(resized_image.path), format, content_type]
    ensure
      tempfile.close!
      tempfile.unlink
    end
  end

  private

  def mime_type_to_format
    case @mime_type
    when 'image/jpeg', 'image/jpg', 'image/heic', 'image/heif' then 'jpg'
    when 'image/png'                                           then 'png'
    when 'image/webp'                                          then 'webp'
    else
      Rails.logger.warn "対応していないMIMEタイプです: #{@mime_type}"
      nil
    end
  end

  def create_tempfile(format)
    tempfile = Tempfile.new(['image', ".#{format}"])
    tempfile.binmode
    tempfile.write(@image_data.read)
    tempfile.rewind
    tempfile
  end
end
