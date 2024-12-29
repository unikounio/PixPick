# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  subject(:entry) { build(:entry) }

  context 'when the image has an allowed MIME type' do
    it 'is valid' do
      expect(entry).to be_valid
    end
  end

  context 'when the image has a disallowed MIME type' do
    before do
      entry.image.attach(
        io: StringIO.new('This is an invalid file'),
        filename: 'invalid.txt',
        content_type: 'text/plain'
      )
    end

    it 'is invalid' do
      expect(entry).not_to be_valid
      expect(entry.errors[:image]).to include('対応していない形式のファイルです')
    end
  end
end
