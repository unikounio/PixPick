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

      unless %w[image/heic image/heif application/octet-stream].include?(mime_type)
        image_processor = image_processor.convert(format).quality(95)
      end

      resized_image = image_processor.call

      File.binread(resized_image.path)
    ensure
      tempfile.close!
      tempfile.unlink
    end
  end

  def self.create_tempfile(image_data, format)
    tempfile = Tempfile.new(['image', ".#{format}"])
    tempfile.binmode
    tempfile.write(image_data.read)
    tempfile.rewind
    tempfile
  end

  private_class_method :create_tempfile
end
