require 'double_bag_ftps'
require 'net/ftp'

When /^the( \w+)? client connects( with TLS)?$/ do
|client_name, with_tls|
  client = TestClient.new(:tls => with_tls)
  client.connect(@server.host, @server.port)
  set_client client_name, client
end

After do
  @client.close if @client
end
