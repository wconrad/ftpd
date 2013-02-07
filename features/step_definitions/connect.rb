require 'double_bag_ftps'
require 'net/ftp'

When /^the client connects( with TLS)?$/ do |with_tls|
  @client = TestClient.new(:tls => with_tls)
  @client.connect(@server.host, @server.port)
end

Then /^the connection is closed$/ do
  @client.should be_closed
end

Then /^the connection is open$/ do
  @client.should be_open
end
