require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe FileSystemErrorTranslator do

    class MockFileSystem

      def with_error
        raise FileSystemError, 'An error occurred'
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

    context 'exception' do
      specify do
        expect {
          translator.with_error
        }.to raise_error CommandError, '450 An error occurred'
      end
    end

  end
end
