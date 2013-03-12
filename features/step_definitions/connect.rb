require 'double_bag_ftps'
require 'net/ftp'

When /^the( \w+)? client connects(?: with (\w+) TLS)?$/ do
|client_name, tls_mode|
  tls_mode ||= :off
  client(client_name).tls_mode = tls_mode.to_sym
  client(client_name).start
  client(client_name).connect(server.host, server.port)
end
