# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntriesHelper do
  describe '#score_button_classes' do
    let(:entry) { create(:entry) }
    let(:user) { create(:user) }

    context 'when the score matches the current user vote score' do
      it 'returns the active button classes' do
        create(:vote, entry:, user:, score: 1)
        result = helper.score_button_classes(entry, user, 1)
        expect(result).to eq('text-white bg-cyan-500 border border-cyan-500')
      end
    end

    context 'when the score does not match the current user vote score' do
      it 'returns the inactive button classes' do
        create(:vote, entry:, user:, score: 2)
        result = helper.score_button_classes(entry, user, 1)
        expect(result).to eq('text-stone-700 bg-white hover:bg-stone-300 transition border border-stone-300')
      end
    end

    context 'when there is no current score for the user' do
      it 'returns the inactive button classes' do
        result = helper.score_button_classes(entry, user, 1)
        expect(result).to eq('text-stone-700 bg-white hover:bg-stone-300 transition border border-stone-300')
      end
    end
  end
end
