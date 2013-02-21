Given /^the test server is started( with TLS)?$/ do |with_tls|
  tls = if :with_tls
          :explicit
        else
          :off
        end
  @server = TestServer.new(:tls => tls)
end
