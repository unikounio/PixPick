# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContestsHelper do
  describe '#tab_link_classes' do
    context 'when current_path matches target_path' do
      it 'returns the active tab classes with extra_classes' do
        result = helper.tab_link_classes('/current_path', '/current_path', 'custom-class')
        expect(result).to eq('bg-white text-stone-700 custom-class')
      end
    end

    context 'when current_path does not match target_path' do
      it 'returns the inactive tab classes with hover effects and extra_classes' do
        result = helper.tab_link_classes('/current_path', '/different_path', 'custom-class')
        expect(result).to eq('bg-stone-100 text-stone-500 hover:bg-white hover:text-stone-700 transition custom-class')
      end
    end
  end
end
