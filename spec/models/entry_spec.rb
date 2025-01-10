# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  subject(:entry) { build(:entry) }

  context 'when the image has an allowed MIME type' do
    it 'is valid' do
      expect(entry).to be_valid
    end
  end

  context 'when the image has a disallowed MIME type' do
    before do
      entry.image.attach(
        io: StringIO.new('This is an invalid file'),
        filename: 'invalid.txt',
        content_type: 'text/plain'
      )
    end

    it 'is invalid' do
      expect(entry).not_to be_valid
      expect(entry.errors[:image]).to include('対応していない形式のファイルです')
    end
  end

  describe '.determine_mime_type' do
    context 'when content_type is application/octet-stream' do
      it 'returns image/jpeg for .jpg' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'image.jpg')
        expect(described_class.determine_mime_type(file)).to eq('image/jpeg')
      end

      it 'returns image/png for .png' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'image.png')
        expect(described_class.determine_mime_type(file)).to eq('image/png')
      end

      it 'returns image/webp for .webp' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'image.webp')
        expect(described_class.determine_mime_type(file)).to eq('image/webp')
      end

      it 'returns image/heic for .heic' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'image.heic')
        expect(described_class.determine_mime_type(file)).to eq('image/heic')
      end

      it 'returns image/heif for .heif' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'image.heif')
        expect(described_class.determine_mime_type(file)).to eq('image/heif')
      end

      it 'returns application/octet-stream for unsupported extension' do
        file = Struct.new(:content_type, :original_filename).new('application/octet-stream', 'file.txt')
        expect(described_class.determine_mime_type(file)).to eq('application/octet-stream')
      end
    end

    context 'when content_type is not application/octet-stream' do
      it 'returns the original content_type' do
        file = Struct.new(:content_type, :original_filename).new('image/jpeg', 'image.jpeg')
        expect(described_class.determine_mime_type(file)).to eq('image/jpeg')
      end
    end
  end
end
