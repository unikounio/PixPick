# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user
  has_many :votes, dependent: :destroy

  validates :drive_file_id, presence: true,
                            uniqueness: { scope: :contest_id, message: :entered }
  validates :drive_permission_id, uniqueness: { scope: :drive_file_id }

  scope :with_total_scores, lambda {
    left_joins(:votes)
      .select('entries.*, COALESCE(SUM(votes.score), 0) AS total_score')
      .group('entries.id')
      .order('total_score DESC')
  }

  ALLOWED_MIME_TYPES = %w[image/jpeg image/jpg image/png image/webp image/heic image/heif].freeze

  def self.upload_and_create_entries!(files, current_user, contest, drive_service)
    files.each do |file|
      drive_file_id, permission_id = upload_to_google_drive(file, contest, drive_service)

      create!(
        user: current_user,
        contest: contest,
        drive_file_id: drive_file_id,
        drive_permission_id: permission_id
      )
    end
  end

  def self.upload_to_google_drive(file, contest, drive_service)
    drive_file_id = drive_service.upload_file(file, contest.drive_file_id)
    raise 'Google Driveへのアップロードに失敗' if drive_file_id.nil?

    permission_id = drive_service.share_file(drive_file_id)
    raise 'Google Drive共有設定に失敗' if permission_id.nil?

    [drive_file_id, permission_id]
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
end
