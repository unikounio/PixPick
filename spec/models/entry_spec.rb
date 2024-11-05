# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }
  let(:access_token) { 'mock_access_token' }
  let(:entries_attributes) do
    [{ media_item_id: '1', base_url: 'https://example.com/photo1.jpg' },
     { media_item_id: '2', base_url: 'https://example.com/photo2.jpg' }]
  end
  let(:base_urls) { ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'] }
  let(:mock_image_data) { 'fake image data' }

  describe 'validations' do
    subject(:entry) { build(:entry, contest: contest, user: user) }

    it { is_expected.to be_valid }

    it 'is invalid without a media_item_id' do
      entry.media_item_id = nil
      expect(entry).not_to be_valid
      expect(entry.errors[:media_item_id]).to include(I18n.t('errors.messages.blank'))
    end

    context 'when a media_item_id is already taken within the same contest' do
      before { create(:entry, media_item_id: entry.media_item_id, contest: contest, user: user) }

      it 'is invalid with a duplicate media_item_id within the same contest' do
        expect(entry).not_to be_valid
        expect(entry.errors[:media_item_id]).to include(I18n.t('activerecord.errors.messages.entered'))
      end
    end

    it 'is valid with the same media_item_id in a different contest' do
      another_contest = create(:contest)
      described_class.create!(media_item_id: '1', base_url: 'https://example.com/photo.jpg',
                              base_url_updated_at: '2024-11-04 00:00:00.700888000 +0900',
                              contest: another_contest, user: user)
      expect(entry).to be_valid
    end
  end

  describe '.create_from_entries_attributes' do
    it 'creates Entry records for each entry attribute' do
      expect do
        described_class.create_from_entries_attributes(entries_attributes, contest.id, user.id)
      end.to change(described_class, :count).by(2)

      entries_attributes.each do |attributes|
        entry = described_class.find_by(media_item_id: attributes[:media_item_id])
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
      images = described_class.get_photo_images(base_urls, access_token)

      expect(images.size).to eq(2)
      expect(images).to all(eq(mock_image_data))
    end

    it 'raises an error if an image cannot be fetched' do
      allow(Faraday).to receive(:get).and_raise(Faraday::ResourceNotFound)

      expect do
        described_class.get_photo_images(base_urls, access_token)
      end.to raise_error(Faraday::ResourceNotFound)
    end

    it 'returns an empty array and logs an error when baseUrls is empty' do
      described_class.get_photo_images([], access_token)
      expect(Rails.logger).to have_received(:error).with('base_urlsが空です')
    end
  end

  describe '.extract_ids_and_urls_from_media_items' do
    it 'extracts media item ids and base urls from media items' do
      media_items = [
        { 'id' => '1', 'mediaFile' => { 'baseUrl' => 'https://example.com/photo1.jpg' } },
        { 'id' => '2', 'mediaFile' => { 'baseUrl' => 'https://example.com/photo2.jpg' } }
      ]
      entries_attributes = described_class.extract_ids_and_urls_from_media_items(media_items)
      expect(entries_attributes).to eq([{ media_item_id: '1', base_url: 'https://example.com/photo1.jpg' },
                                      { media_item_id: '2', base_url: 'https://example.com/photo2.jpg' }].to_json)
    end

    it 'returns an empty array and logs an error when media_items is empty' do
      allow(Rails.logger).to receive(:error)
      entries_attributes = described_class.extract_ids_and_urls_from_media_items([])

      expect(entries_attributes).to eq([])
      expect(Rails.logger).to have_received(:error).with('media_itemsが空です')
    end
  end
end
