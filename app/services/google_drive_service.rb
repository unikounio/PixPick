# frozen_string_literal: true

class GoogleDriveService
  def initialize(access_token)
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = access_token
  end

  def create_folder(folder_name)
    file_object = Google::Apis::DriveV3::File.new(
      name: folder_name,
      mime_type: 'application/vnd.google-apps.folder'
    )

    begin
      folder = @service.create_file(file_object, fields: 'id')
      folder.id
    rescue Google::Apis::Error => e
      Rails.logger.error("フォルダ作成に失敗しました: #{e.message}")
      nil
    end
  end
end
