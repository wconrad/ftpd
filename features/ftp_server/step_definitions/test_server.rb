Given /^the test server is started$/ do
  @server = TestServer.new
  @server.start
end

Given /^the test server is started with(?: (\w+) TLS)?$/ do |mode|
  mode ||= 'explicit'
  @server = TestServer.new
  @server.tls = mode.to_sym
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
