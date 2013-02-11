require 'double_bag_ftps'
require 'net/ftp'

When /^the client connects( with TLS)?$/ do |with_tls|
  @client = TestClient.new(:tls => with_tls)
  @client.connect(@server.host, @server.port)
end

After do
  @client.close if @client
end
