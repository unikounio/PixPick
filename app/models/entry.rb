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

      resized_image_data, format, content_type = resize_and_convert_image(
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

  def self.create_ranked_entries_with_scores(entries_with_scores)
    calculate_ranks(entries_with_scores).map do |rank, entry|
      {
        rank: rank,
        entry: entry,
        total_score: entry.total_score
      }
    end
  end

  private

  def validate_image_format
    return unless image.attached?

    return if ALLOWED_MIME_TYPES.include?(image.content_type)

    errors.add(:image, '対応していない形式のファイルです')
  end

  def self.resize_and_convert_image(image_data, mime_type, width, height)
    format = mime_type_to_format(mime_type) || 'webp'
    tempfile = create_tempfile(image_data, format)

    begin
      image_processor = ImageProcessing::Vips
                        .source(tempfile.path)
                        .saver(strip: true)
                        .resize_to_fit(width, height)

      if %w[image/heic image/heif application/octet-stream].include?(mime_type)
        content_type = mime_type
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

  def self.create_tempfile(image_data, format)
    tempfile = Tempfile.new(['image', ".#{format}"])
    tempfile.binmode
    tempfile.write(image_data.read)
    tempfile.rewind
    tempfile
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

  def self.calculate_ranks(entries)
    ranked_entries = []
    current_rank = 0
    previous_score = nil

    entries.each_with_index do |entry, index|
      if entry.total_score != previous_score
        current_rank = index + 1
        previous_score = entry.total_score
      end

      ranked_entries << [current_rank, entry]
    end

    ranked_entries
  end

  private_class_method :resize_and_convert_image, :create_tempfile, :mime_type_to_format, :calculate_ranks
end
