require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe FileSystemErrorTranslator do

    class MockFileSystem

      def with_error(klass)
        raise klass, 'An error occurred'
      end

      def without_error
        123
      end

    end

    subject(:translator) do
      FileSystemErrorTranslator.new(MockFileSystem.new)
    end

    context 'missing method' do
      specify do
        expect {
          translator.no_such_method
        }.to raise_error NoMethodError, /no_such_method/
      end
    end

    context 'no exception' do
      its(:without_error) {should == 123}
    end

    context 'FileSystemError' do
      specify do
        expect {
          translator.with_error(FileSystemError)
        }.to raise_error CommandError, '550 An error occurred'
      end
    end

    context 'PermanentFileSystemError' do
      specify do
        expect {
          translator.with_error(PermanentFileSystemError)
        }.to raise_error CommandError, '550 An error occurred'
      end
    end

    context 'TransientFileSystemError' do
      specify do
        expect {
          translator.with_error(TransientFileSystemError)
        }.to raise_error CommandError, '450 An error occurred'
      end
    end

  end
end
