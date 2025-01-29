# frozen_string_literal: true

module ApplicationHelper
  def default_meta_tags
    {
      site: 'PixPick',
      reverse: true,
      charset: 'utf-8',
      description: 'PixPickは、家族や友人と写真のコンテストを開催できるアプリです。',
      keywords: 'PixPick, 写真, 写真整理, 写真選び, コンテスト, ベストショット, アルバム, アルバム共有',
      og: {
        title: :title,
        type: 'website',
        site_name: 'PixPick',
        description: :description,
        image: image_url('ogp.png'),
        url: 'https://pixpick.jp',
        local: 'ja-JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@unikounio512'
      }
    }
  end
end
