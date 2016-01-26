# frozen_string_literal: true

require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe ExceptionTranslator do

    class FooError < StandardError ; end
    class BarError < StandardError ; end

    subject(:translator) {ExceptionTranslator.new}
    let(:message) {'An error happened'}

    context '(registered exception)' do
      before(:each) do
        translator.register_exception FooError
      end
      it 'should translate the exception' do
        expect {
          subject.translate_exceptions do
            raise FooError, message
          end
        }.to raise_error PermanentFileSystemError, message
      end
    end

    context '(unregistered exception)' do
      it 'should pass the exception' do
        expect {
          subject.translate_exceptions do
            raise BarError, message
          end
        }.to raise_error BarError, message
      end
    end

  end
end
