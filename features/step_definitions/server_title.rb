Then /^the server returns its title$/ do
  step 'the server returns its name'
  step 'the server returns its version'
end

Then /^the server returns its name$/ do
  @response.should include @server.server_name
end

Then /^the server returns its version$/ do
  @response.should =~ /\b\d+\.\d+\.\d+\b/
end
