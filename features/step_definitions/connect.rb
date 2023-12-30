# frozen_string_literal: true

require 'net/ftp'

When /^the( \w+)? client connects(?: with (\w+) TLS)?$/ do
  |client_name, tls_mode|
  begin
    tls_mode ||= 'off'
    c = client(client_name)
    c.tls_mode = tls_mode.to_sym
    c.start
    c.connect(server.host, server.port)
  rescue TestClient::CannotTestTls => e
    pending(e.message)
  end
end

When /^the (\d+)rd client tries to connect$/ do |client_name|
  client(client_name.to_s).start
  capture_error do
    client(client_name.to_s).connect(server.host, server.port)
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
  expect(client).to be_connected
end

Then /^the client should not be connected$/ do
  expect(client).to_not be_connected
end
