# frozen_string_literal: true

module Ftpd
  describe ListPath do

    include ListPath

    it 'should replace a missing path with "."' do
      expect(list_path(nil)).to eq('.')
    end

    it 'should replace a switch with nothing' do
      expect(list_path('-a')).to eq('')
    end

    it 'should preserve a filename with a dash in it' do
      expect(list_path('foo-bar')).to eq('foo-bar')
    end

  end
end
