When /^the client successfully queries system ID$/ do
  @reply = @client.system
end

Then /^the server returns a system ID reply$/ do
  step 'the server returns a "UNIX Type: L8" reply'
end
