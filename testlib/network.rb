module TestLib
  module Network

    extend self

    def ipv6_supported?
      begin
        server = TCPServer.new("::1", 0)
        server.close
        true
      rescue Errno::EADDRNOTAVAIL
        false
      end
    end

  end
end
