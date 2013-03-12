When /^the client successfully requests status$/ do
  @status = client.status
end

When /^the client requests status$/ do
  capture_error do
    step 'the client successfully requests status'
  end
end

Then /^the server returns its name$/ do
  @status.should include @server.server_name
end

Then /^the server returns its version$/ do
  @status.should =~ /\b\d+\.\d+\.\d+\b/
end
