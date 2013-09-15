require 'double_bag_ftps'
require 'net/ftp'

When /^the( \w+)? client connects(?: with (\w+) TLS)?$/ do
|client_name, tls_mode|
  tls_mode ||= 'off'
  client(client_name).tls_mode = tls_mode.to_sym
  client(client_name).start
  client(client_name).connect(server.host, server.port)
end

When /^the (\d+)rd client tries to connect$/ do |client_name|
  client(client_name).start
  capture_error do
    client(client_name).connect(server.host, server.port)
  end
end

When /^the (\S+) client connects from (\S+)$/ do
|client_name, source_ip|
  client(client_name).connect_from(source_ip, server.host, server.port)
end

When /^the (\S+) client tries to connect from (\S+)$/ do
|client_name, source_ip|
  capture_error do
    step "the #{client_name} client connects from #{source_ip}"
  end
end

Then /^the client should be connected$/ do
  client.should be_connected
end

Then /^the client should not be connected$/ do
  client.should_not be_connected
end
