# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }
  let(:access_token) { 'mock_access_token' }
  let(:base_urls) { ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'] }
  let(:mock_image_data) { 'fake image data' }

  describe 'validations' do
    subject(:entry) { build(:entry, contest: contest, user: user) }

    it { is_expected.to be_valid }

    it 'is invalid without a base_url' do
      entry.base_url = nil
      expect(entry).not_to be_valid
      expect(entry.errors[:base_url]).to include(I18n.t('errors.messages.blank'))
    end

    context 'when a base_url is already taken within the same contest' do
      before { create(:entry, base_url: entry.base_url, contest: contest, user: user) }

      it 'is invalid with a duplicate base_url within the same contest' do
        expect(entry).not_to be_valid
        expect(entry.errors[:base_url]).to include(I18n.t('activerecord.errors.messages.entered'))
      end
    end

    it 'is valid with the same base_url in a different contest' do
      another_contest = create(:contest)
      described_class.create!(base_url: 'https://example.com/photo.jpg', contest: another_contest, user: user)
      expect(entry).to be_valid
    end
  end

  describe '.create_from_base_urls' do
    it 'creates Entry records for each base URL' do
      expect do
        described_class.create_from_base_urls(base_urls, contest.id, user.id)
      end.to change(described_class, :count).by(2)

      base_urls.each do |url|
        entry = described_class.find_by(base_url: url)
        expect(entry).not_to be_nil
        expect(entry.contest_id).to eq(contest.id)
        expect(entry.user_id).to eq(user.id)
      end
    end
  end

  describe '.get_photo_images' do
    let(:base_urls) { ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'] }
    let(:access_token) { 'mock_access_token' }
    let(:mock_image_data) { 'fake image data' }

    before do
      allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response, body: mock_image_data))
      allow(Rails.logger).to receive(:error)
    end

    it 'fetches images from baseUrls with correct size parameters' do
      width = 256
      height = 256
      images = described_class.get_photo_images(base_urls, access_token, width, height)

      expect(images.size).to eq(2)
      expect(images).to all(eq(mock_image_data))
    end

    it 'raises an error if an image cannot be fetched' do
      allow(Faraday).to receive(:get).and_raise(Faraday::ResourceNotFound)

      expect do
        described_class.get_photo_images(base_urls, access_token, 256, 256)
      end.to raise_error(Faraday::ResourceNotFound)
    end

    it 'returns an empty array and logs an error when baseUrls is empty' do
      described_class.get_photo_images([], access_token, 256, 256)
      expect(Rails.logger).to have_received(:error).with('base_urlsが空です')
    end
  end

  describe '.extract_base_urls' do
    it 'extracts baseUrls from media items' do
      media_items = [
        { 'mediaFile' => { 'baseUrl' => 'https://example.com/photo1.jpg' } },
        { 'mediaFile' => { 'baseUrl' => 'https://example.com/photo2.jpg' } }
      ]
      base_urls = described_class.extract_base_urls(media_items)
      expect(base_urls).to eq(%w[https://example.com/photo1.jpg https://example.com/photo2.jpg])
    end

    it 'returns an empty array and logs an error when media_items is empty' do
      allow(Rails.logger).to receive(:error)
      base_urls = described_class.extract_base_urls([])

      expect(base_urls).to eq([])
      expect(Rails.logger).to have_received(:error).with('media_itemsが空です')
    end
  end
end
