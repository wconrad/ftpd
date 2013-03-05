require 'double_bag_ftps'
require 'net/ftp'

When /^the( \w+)? client connects(?: with (\w+) TLS)?$/ do
|client_name, tls_mode|
  tls_mode ||= :off
  client = TestClient.new(:tls => tls_mode.to_sym)
  client.connect(server.host, server.port)
  set_client client_name, client
end

After do
  @client.close if @client
end
