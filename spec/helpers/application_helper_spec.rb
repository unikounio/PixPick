# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#default_meta_tags' do
    it 'returns the default meta tags as a hash' do
      meta_tags = helper.default_meta_tags

      expect(meta_tags[:site]).to eq('PixPick')
      expect(meta_tags[:description]).to eq('PixPickは、家族や友人と写真のコンテストを開催できるアプリです。')
    end

    it 'includes Open Graph and Twitter meta tags' do
      meta_tags = helper.default_meta_tags

      expect(meta_tags[:og][:site_name]).to eq('PixPick')
      expect(meta_tags[:twitter][:card]).to eq('summary_large_image')
    end
  end
end
