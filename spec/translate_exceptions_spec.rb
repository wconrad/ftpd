# frozen_string_literal: true

module Ftpd
  describe TranslateExceptions do

    class FooError < StandardError ; end
    class BarError < StandardError ; end

    class Subject

      include TranslateExceptions

      def initialize
        translate_exception FooError
      end

      def raise_error(error, message)
        raise error, message
      end
      translate_exceptions :raise_error

    end

    let(:subject) {Subject.new}
    let(:message) {'An error happened'}

    it 'should translate a registered error' do
      expect {
        subject.raise_error(FooError, message)
      }.to raise_error PermanentFileSystemError, message
    end

    it 'should pass through an unregistered error' do
      expect {
        subject.raise_error(BarError, message)
      }.to raise_error BarError, message
    end

  end
end
