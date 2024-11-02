# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :base_url, presence: true,
                       uniqueness: { scope: :contest_id, message: :entered }

  def self.create_from_base_urls(base_urls, contest_id, user_id)
    base_urls.each do |url|
      create!(
        base_url: url,
        contest_id: contest_id,
        user_id: user_id
      )
    end
  end

  def self.get_photo_images(base_urls, access_token, width, hight)
    if base_urls.present?
      base_urls.map do |url|
        response = Faraday.get("#{url}=w#{width}-h#{hight}") do |req|
          req.headers['Authorization'] = "Bearer #{access_token}"
        end
        response.body
      end
    else
      Rails.logger.error 'base_urlsが空です'
      []
    end
  end

  def self.extract_base_urls(media_items)
    if media_items.present?
      media_items.map { |item| item['mediaFile']['baseUrl'] }
    else
      Rails.logger.error 'media_itemsが空です'
      []
    end
  end
end
