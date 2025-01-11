# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user
  has_many :votes, dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200], preprocessed: true
  end

  validate :validate_image_format

  scope :with_total_scores, lambda {
    left_joins(:votes)
      .select('entries.*, COALESCE(SUM(votes.score), 0) AS total_score')
      .group('entries.id')
      .order('total_score DESC')
  }

  ALLOWED_MIME_TYPES = %w[image/jpeg image/jpg image/png image/webp image/heic image/heif].freeze

  def self.upload_and_create_entries!(file, current_user, contest)
    transaction do
      entry = create!(user: current_user, contest: contest)

      resized_image_data, format, content_type = EntryResizer.resize_and_convert_image(
        file,
        file.content_type,
        400, 400
      )

      entry.image.attach(
        io: StringIO.new(resized_image_data),
        filename: file.original_filename.sub(/\.\w+$/, ".#{format}"),
        content_type:
      )
    end
  end

  def self.validate_mime_type(files)
    invalid_files = files.reject do |file|
      detected_mime_type = determine_mime_type(file)
      ALLOWED_MIME_TYPES.include?(detected_mime_type)
    end

    return nil if invalid_files.empty?

    '対応していない形式のファイルが含まれています。画面を更新してやり直してください。'
  end

  def self.determine_mime_type(file)
    if file.content_type == 'application/octet-stream'
      case File.extname(file.original_filename).downcase
      when '.jpg', '.jpeg'
        'image/jpeg'
      when '.png'
        'image/png'
      when '.webp'
        'image/webp'
      when '.heic'
        'image/heic'
      when '.heif'
        'image/heif'
      else
        'application/octet-stream'
      end
    else
      file.content_type
    end
  end

  private

  def validate_image_format
    return unless image.attached?

    return if ALLOWED_MIME_TYPES.include?(image.content_type)

    errors.add(:image, '対応していない形式のファイルです')
  end
end
