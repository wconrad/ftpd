Given /^the test server is started$/ do
  @server = TestServer.new
  @server.start
end

Given /^the test server is started with TLS$/ do
  @server = TestServer.new
  @server.tls = :explicit
  @server.start
end

Given /^the test server is started with debug$/ do
  @server = TestServer.new
  @server.debug = true
  @server.start
end

Given /^the test server is started without (\w+)$/ do |feature|
  @server = TestServer.new
  @server.send "#{feature}=", false
  @server.start
end
