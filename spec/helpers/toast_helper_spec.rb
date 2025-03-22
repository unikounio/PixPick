# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToastHelper do
  describe '#toast_border_css' do
    it 'returns success border CSS classes for :success type' do
      expect(helper.toast_border_css(:success)).to eq('border-stone-200')
    end

    it 'returns error border CSS classes for other types' do
      expect(helper.toast_border_css(:error)).to eq('border-red-300')
    end
  end
end
