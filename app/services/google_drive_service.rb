# frozen_string_literal: true

class GoogleDriveService
  def initialize
    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = session[:access_token]
  end
end
