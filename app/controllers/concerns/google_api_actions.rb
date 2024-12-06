# frozen_string_literal: true

module GoogleApiActions
  extend ActiveSupport::Concern

  private

  def ensure_valid_access_token!
    return if session[:token_expires_at].nil? || !current_user.token_expired?(session[:token_expires_at])

    result = current_user.request_token_refresh(session[:refresh_token])
    if result.present?
      store_access_token(result)
    else
      sign_out current_user
      redirect_to root_path, alert: t('activerecord.errors.messages.failed_to_refresh_token')
    end
  end

  def store_access_token(result)
    session[:access_token] = result['access_token']
    session[:token_expires_at] = Time.current + result['expires_in'].seconds
  end

  def set_drive_service
    @drive_service = GoogleDriveService.new(session[:access_token])
  end

  def setup_drive_folder
    folder_id = @drive_service.create_folder(@contest.name)

    if folder_id.present?
      permission_id = @drive_service.share_file(folder_id)
      return nil if permission_id.nil?
    end

    [folder_id, permission_id]
  end
end
