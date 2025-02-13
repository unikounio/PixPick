# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToastHelper do
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
end
