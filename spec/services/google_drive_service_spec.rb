# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleDriveService do
  let(:drive_service) { described_class.new('mock_access_token') }
  let(:client) { drive_service.instance_variable_get(:@service) }

  describe '#create_folder' do
    let(:folder_response) { instance_double(Google::Apis::DriveV3::File, id: 'test_folder_id') }

    context 'when folder creation is successful' do
      it 'returns the folder ID' do
        allow(client).to receive(:create_file).and_return(folder_response)

        result = drive_service.create_folder('Test Folder')
        expect(result).to eq('test_folder_id')
      end
    end

    context 'when folder creation fails' do
      it 'logs an error and returns nil' do
        allow(client).to receive(:create_file).and_raise(Google::Apis::Error.new('API Error'))
        allow(Rails.logger).to receive(:error)

        result = drive_service.create_folder('Test Folder')
        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/フォルダ作成に失敗しました: API Error/)
      end
    end
  end

  describe '#share_file' do
    let(:permission_response) { instance_double(Google::Apis::DriveV3::Permission, id: 'test_permission_id') }

    context 'when file sharing is successful' do
      it 'returns the permission ID' do
        allow(client).to receive(:create_permission).and_return(permission_response)

        result = drive_service.share_file('test_file_id')
        expect(result).to eq('test_permission_id')
      end
    end

    context 'when file sharing fails' do
      it 'logs an error and returns nil' do
        allow(client).to receive(:create_permission).and_raise(Google::Apis::Error.new('API Error'))
        allow(Rails.logger).to receive(:error)

        result = drive_service.share_file('test_file_id')
        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/フォルダ共有に失敗しました: API Error/)
      end
    end
  end

  describe '#upload_file' do
    let(:file) do
      instance_double(
        ActionDispatch::Http::UploadedFile,
        original_filename: 'test_image.jpg',
        path: '/path/to/mock/file',
        content_type: 'image/jpeg'
      )
    end
    let(:folder_id) { 'mock_folder_id' }

    context 'when the file upload is successful' do
      let(:mock_response) { instance_double(Google::Apis::DriveV3::File, id: 'mock_drive_file_id') }

      before do
        allow(client).to receive(:create_file).with(
          { name: file.original_filename, parents: [folder_id] },
          upload_source: file.path,
          content_type: file.content_type
        ).and_return(mock_response)
      end

      it 'returns the drive file ID' do
        result = drive_service.upload_file(file, folder_id)
        expect(result).to eq('mock_drive_file_id')
      end
    end

    context 'when the file upload fails' do
      before do
        allow(client).to receive(:create_file).with(
          { name: file.original_filename, parents: [folder_id] },
          upload_source: file.path,
          content_type: file.content_type
        ).and_raise(Google::Apis::Error.new('Upload failed'))
      end

      it 'logs an error and returns nil' do
        allow(Rails.logger).to receive(:error)
        result = drive_service.upload_file(file, folder_id)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with('Google Driveアップロードに失敗しました: Upload failed')
      end
    end
  end
end
