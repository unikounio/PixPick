# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user
  has_many :votes, dependent: :destroy

  validates :drive_file_id, presence: true,
                            uniqueness: { scope: :contest_id, message: :entered }
  validates :drive_permission_id, uniqueness: { scope: :drive_file_id }

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
end
