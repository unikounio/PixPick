# frozen_string_literal: true

module ImageResizer
  extend ActiveSupport::Concern

  class_methods do
    def resize_and_convert_image(file_path, mime_type, width, height)
      image_processor = ImageProcessing::Vips
                        .source(file_path)
                        .saver(strip: true)
                        .resize_to_fit(width, height)

      if %w[image/heic image/heif application/octet-stream].include?(mime_type)
        content_type = mime_type
      else
        image_processor = image_processor.saver(format: 'webp', quality: 90)
        content_type = 'image/webp'
      end

      resized_image = image_processor.call

      [File.binread(resized_image.path), content_type]
    end
  end
end
