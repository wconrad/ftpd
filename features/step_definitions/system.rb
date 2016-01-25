When /^the client successfully queries system ID$/ do
  @reply = client.system
  # Prior to ruby-2.3.0, the #system call returned a string ending in
  # a new-line.
  @reply += "\n" unless @reply =~ /\n$/
end

Then /^the server returns a system ID reply$/ do
  step 'the server returns a "UNIX Type: L8" reply'
end
