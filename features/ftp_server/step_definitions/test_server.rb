Given /^the test server is started( with TLS)?$/ do |with_tls|
  @server = TestServer.new(:tls => with_tls)
end
