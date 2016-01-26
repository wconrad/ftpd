# frozen_string_literal: true

module Ftpd
  class Config

    # The number of seconds to delay before replying.  This is for
    # testing client timeouts.
    # Defaults to 0 (no delay).
    #
    # Change to this attribute only take effect for new sessions.

    attr_accessor :response_delay

  end
end
