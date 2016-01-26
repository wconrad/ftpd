# frozen_string_literal: true

require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Ftpd
  module ListFormat
    describe Eplf do

      context '(file)' do

        let(:file_info) do
          FileInfo.new(:ftype => 'file',
                       :mode => 0100644,
                       :mtime => Time.utc(2013, 3, 3, 8, 38, 0),
                       :path => 'foo',
                       :size => 1234)
        end
        subject(:formatter) {Eplf.new(file_info)}

        it 'should produce EPLF format' do
          expect(formatter.to_s).to eq "+r,s1234,m1362299880\tfoo"
        end

      end

      context '(directory)' do

        let(:file_info) do
          FileInfo.new(:ftype => 'directory',
                       :mode => 0100644,
                       :mtime => Time.utc(2013, 3, 3, 8, 38, 0),
                       :path => 'foo',
                       :size => 1024)
        end
        subject(:formatter) {Eplf.new(file_info)}

        it 'should produce EPLF format' do
          expect(formatter.to_s).to eq "+/,m1362299880\tfoo"
        end

      end

      context '(with identifier)' do

        let(:file_info) do
          FileInfo.new(:ftype => 'file',
                       :mode => 0100644,
                       :mtime => Time.utc(2013, 3, 3, 8, 38, 0),
                       :path => 'foo',
                       :identifier => '1234.5678',
                       :size => 1234)
        end
        subject(:formatter) {Eplf.new(file_info)}

        it 'should produce EPLF format' do
          expect(formatter.to_s).to eq "+r,s1234,m1362299880,i1234.5678\tfoo"
        end

      end

    end
  end
end
