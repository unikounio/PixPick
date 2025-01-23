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

  def tailwind_classes_for(flash_type)
    {
      notice: 'bg-white border-l-4 border-green-500 text-black',
      participation_notice: 'bg-white border-l-4 border-green-500 text-black',
      alert: 'bg-white border-l-4 border-red-500 text-black',
      participation_alert: 'bg-white border-l-4 border-red-500 text-black'
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def notice_type?(flash_type)
    %w[notice participation_notice].include?(flash_type.to_s)
  end

  def alert_type?(flash_type)
    %w[alert participation_alert].include?(flash_type.to_s)
  end

  def toast_border_css(type)
    if type == :success
      'border-stone-200 dark:bg-stone-800 dark:border-stone-700'
    else
      'border-red-300 dark:bg-red-800 dark:border-red-700'
    end
  end

  def toast_text_css(type)
    if type == :success
      'text-stone-700 dark:text-stone-400'
    else
      'text-stone-700 dark:text-stone-100'
    end
  end

  def current_contest_or_contests_index_path(contest, current_user)
    if contest&.persisted?
      contest_path(contest)
    else
      user_contests_path(current_user)
    end
  end
end
