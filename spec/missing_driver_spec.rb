require File.expand_path('spec_helper', File.dirname(__FILE__))

module Ftpd
  describe MissingDriver do

    it 'raises a MissingDriverError for any method' do
      expect {
        MissingDriver.new.foo
      }.to raise_error MissingDriverError,
        "This server has no driver.  Please give it one."
    end

  end
end
