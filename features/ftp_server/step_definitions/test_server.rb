Given /^the test server is started$/ do
  @server = TestServer.new(:tls => :off)
end

Given /^the test server is started with TLS$/ do
  @server = TestServer.new(:tls => :explicit)
end

Given /^the test server is started with debug$/ do
  @server = TestServer.new(:tls => :off,
                           :debug => true)
end
