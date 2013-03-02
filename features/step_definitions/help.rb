When /^the client successfully asks for help(?: for "(.*?)")?$/ do
|command|
  @help_reply = @client.help(command)
end

Then /^the server should return a list of commands$/ do
  commands = @help_reply.scan(/\b([A-Z][A-Z]+)\b/).flatten
  commands.should include 'NOOP'
  commands.should include 'USER'
end

Then /^the server should return help for "(.*?)"$/ do |command|
  @help_reply.should =~ /Command #{command} is recognized/
end

Then /^the server should return no help for "(.*?)"$/ do |command|
  @help_reply.should =~ /Command #{command} is not recognized/
end
