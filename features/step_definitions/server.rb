Given /^the server is started$/ do
  @server = TestServer.new
end

After do
  @server.stop if @server
end
