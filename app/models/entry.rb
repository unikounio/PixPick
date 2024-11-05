# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :media_item_id, presence: true,
                            uniqueness: { scope: :contest_id, message: :entered }

  def self.create_from_entries_attributes(entries_attributes, contest_id, user_id)
    entries_attributes.each do |attributes|
      create!(
        media_item_id: attributes[:media_item_id],
        base_url: attributes[:base_url],
        base_url_updated_at: Time.current,
        contest_id: contest_id,
        user_id: user_id
      )
    end
  end

  def self.get_photo_images(base_urls, access_token, width = 256, height = 256)
    if base_urls.present?
      base_urls.map do |url|
        response = Faraday.get("#{url}=w#{width}-h#{height}") do |req|
          req.headers['Authorization'] = "Bearer #{access_token}"
        end
        response.body
      end
    else
      Rails.logger.error 'base_urlsが空です'
      []
    end
  end

  def self.extract_ids_and_urls_from_media_items(media_items)
    if media_items.present?
      media_items.map do |item|
        { media_item_id: item['id'], base_url: item['mediaFile']['baseUrl'] }
      end.to_json
    else
      Rails.logger.error 'media_itemsが空です'
      []
    end
  end

  def refresh_base_url(access_token)
    response = Faraday.get("https://photoslibrary.googleapis.com/v1/mediaItems/#{media_item_id}") do |conn|
      conn.headers['Authorization'] = "Bearer #{access_token}"
    end

    if response.success?
      media_item = JSON.parse(response.body)
      update!(base_url: media_item['baseUrl'], base_url_updated_at: Time.current)
      base_url
    else
      Rails.logger.error "mediaItemの取得に失敗: #{response.status} - #{response.body}"
      nil
    end
  end
end
