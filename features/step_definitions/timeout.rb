When /^the client is idle for (\S+) seconds$/ do |seconds|
  sleep seconds.to_f
end

Then /^the client is connected$/ do
  client.should be_connected
end

Then /^the client is not connected$/ do
  client.should_not be_connected
end
