# frozen_string_literal: true

class ContestSetupJob < ApplicationJob
  include GoogleApiActions

  queue_as :default

  discard_on StandardError do |job, error|
    contest = Contest.find_by(id: job.arguments.first)
    contest.destroy!
    Rails.logger.error "コンテストのセットアップに失敗し、削除しました。コンテストID: #{contest.id}"
    Rails.logger.error error.message
  end

  def perform(contest_id, access_token)
    @contest = Contest.find(contest_id)
    @drive_service = GoogleDriveService.new(access_token)
    folder_id, permission_id = setup_drive_folder

    return if folder_id.present? && @contest.save_drive_ids(folder_id, permission_id)

    raise 'Google Driveのフォルダ作成または保存に失敗しました'
  end
end
