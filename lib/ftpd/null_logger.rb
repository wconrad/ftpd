# frozen_string_literal: true

module Ftpd

  # A logger that does not log.
  # Quacks enough like a Logger to fool Ftpd.

  class NullLogger

    def self.stub(method_name)
      define_method method_name do |*args|
      end
    end

    stub :unknown
    stub :fatal
    stub :error
    stub :warn
    stub :info
    stub :debug

  end

end
