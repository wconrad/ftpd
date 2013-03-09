require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe NullLogger do

    subject {NullLogger.new}

    def self.should_stub(method)
      describe "#{method}" do
        specify do
          subject.should respond_to method
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
