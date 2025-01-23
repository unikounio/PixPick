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

  describe '#tailwind_classes_for' do
    it 'returns the correct Tailwind CSS classes for notice' do
      expect(helper.tailwind_classes_for(:notice)).to eq('bg-white border-l-4 border-green-500 text-black')
    end

    it 'returns the correct Tailwind CSS classes for alert' do
      expect(helper.tailwind_classes_for(:alert)).to eq('bg-white border-l-4 border-red-500 text-black')
    end

    it 'returns the input flash type string if it does not match predefined types' do
      expect(helper.tailwind_classes_for(:unknown_type)).to eq('unknown_type')
    end
  end

  describe '#notice_type?' do
    it 'returns true for notice' do
      expect(helper.notice_type?('notice')).to be(true)
    end

    it 'returns true for participation_notice' do
      expect(helper.notice_type?('participation_notice')).to be(true)
    end

    it 'returns false for other types' do
      expect(helper.notice_type?('alert')).to be(false)
    end
  end

  describe '#alert_type?' do
    it 'returns true for alert' do
      expect(helper.alert_type?('alert')).to be(true)
    end

    it 'returns true for participation_alert' do
      expect(helper.alert_type?('participation_alert')).to be(true)
    end

    it 'returns false for other types' do
      expect(helper.alert_type?('notice')).to be(false)
    end
  end

  describe '#toast_border_css' do
    it 'returns success border CSS classes for :success type' do
      expect(helper.toast_border_css(:success)).to eq('border-stone-200 dark:bg-stone-800 dark:border-stone-700')
    end

    it 'returns error border CSS classes for other types' do
      expect(helper.toast_border_css(:error)).to eq('border-red-300 dark:bg-red-800 dark:border-red-700')
    end
  end

  describe '#toast_text_css' do
    it 'returns success text CSS classes for :success type' do
      expect(helper.toast_text_css(:success)).to eq('text-stone-700 dark:text-stone-400')
    end

    it 'returns error text CSS classes for other types' do
      expect(helper.toast_text_css(:error)).to eq('text-stone-700 dark:text-stone-100')
    end
  end

  describe '#current_contest_or_contests_index_path' do
    let(:user) { create(:user) }

    context 'when the contest is persisted' do
      it 'returns the contest path' do
        contest = create(:contest)
        expect(helper.current_contest_or_contests_index_path(contest, user)).to eq(contest_path(contest))
      end
    end

    context 'when the contest is not persisted' do
      it 'returns the contests index path' do
        contest = Contest.new
        expect(helper.current_contest_or_contests_index_path(contest, user)).to eq(user_contests_path(user))
      end
    end
  end
end
