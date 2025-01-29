# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlashHelper do
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
end
