# frozen_string_literal: true

module Ftpd
  describe NullLogger do

    subject {NullLogger.new}

    def self.should_stub(method)
      describe "#{method}" do
        specify do
          expect(subject).to respond_to method
        end
      end
    end

    should_stub :unknown
    should_stub :fatal
    should_stub :error
    should_stub :warn
    should_stub :info
    should_stub :debug

  end
end
