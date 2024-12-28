# frozen_string_literal: true

class EntryUploadJob < ApplicationJob
  queue_as :default

  discard_on StandardError do |_job, error|
    Rails.logger.error "エントリーのアップロード処理中に次のエラーが発生: #{error.message}"
  end

  def perform(file_data, user_id, contest_id)
    current_user = User.find(user_id)
    contest = Contest.find(contest_id)

    redis = Redis.new
    redis.set("uploading_#{contest.id}", 'processing')

    file_data.each do |file_info|
      Entry.upload_and_create_entries!(file_info, current_user, contest)
    end

    redis.set("uploading_#{contest.id}", 'completed')
  end
end
