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

  def share_file(file_id)
    permission_object = Google::Apis::DriveV3::Permission.new(
      type: 'anyone',
      role: 'writer'
    )

    begin
      permission = @service.create_permission(file_id, permission_object, fields: 'id')
      permission.id
    rescue Google::Apis::Error => e
      Rails.logger.error("フォルダ共有に失敗しました: #{e.message}")
      nil
    end
  end

  def upload_file(file, folder_id)
    file_object = {
      name: file.original_filename,
      parents: [folder_id]
    }

    uploaded_file = @service.create_file(
      file_object,
      upload_source: file.path,
      content_type: file.content_type
    )

    uploaded_file.id
  rescue Google::Apis::Error => e
    Rails.logger.error("Google Driveアップロードに失敗しました: #{e.message}")
    nil
  end
end
