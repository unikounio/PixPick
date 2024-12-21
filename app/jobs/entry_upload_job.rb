# frozen_string_literal: true

class EntryUploadJob < ApplicationJob
  queue_as :default

  discard_on StandardError do |_job, error|
    Rails.logger.error "エントリーのアップロード処理中に次のエラーが発生: #{error.message}"
  end

  def perform(file_data, user_id, contest_id, access_token)
    current_user = User.find(user_id)
    contest = Contest.find(contest_id)
    drive_service = GoogleDriveService.new(access_token)
    file_data.each do |file_info|
      Entry.upload_and_create_entries!(file_info, current_user, contest, drive_service)
    end
  end
end
