def server
  @server ||= TestServer.new
end

Given /^the test server is started$/ do
  server.start
end

Given /^the test server has TLS mode "(\w+)"$/ do |mode|
  server.tls = mode.to_sym
end

Given /^the test server has logging (enabled|disabled)$/ do |state|
  server.logging = state == 'enabled'
end

Given /^the test server lacks (\w+)$/ do |feature|
  server.send "#{feature}=", false
end

Given /^the test server has auth level "(.*?)"$/ do |auth_level|
  auth_level = Ftpd.const_get(auth_level)
  server.auth_level = auth_level
end

Given /^the test server has session timeout set to (\S+) seconds$/ do
|timeout|
  server.session_timeout = timeout.to_f
end

Given /^the test server has session timeout disabled$/ do
  server.session_timeout = nil
end

Given /^the test server disallows low data ports$/ do
  server.allow_low_data_ports = false
end

Given /^the test server allows low data ports$/ do
  server.allow_low_data_ports = true
end
