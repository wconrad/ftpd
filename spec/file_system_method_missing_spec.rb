require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe FileSystemMethodMissing do

    class MockFileSystem

      def existing_method
        123
      end

    end

    subject(:wrapper) do
      FileSystemMethodMissing.new(MockFileSystem.new)
    end

    context 'missing method' do
      specify do
        expect {
          wrapper.no_such_method
        }.to raise_error CommandError, '502 Command not implemented'
      end
    end

    context 'existing method' do
      its(:existing_method) {should == 123}
    end

  end
end
