When /^the client successfully gets size of (text|binary) "(.*?)"$/ \
do |mode, remote_path|
  @size = client.get_size mode, remote_path
end

When /^the client gets size of (\S+) "(.*?)"$/ do |mode, path|
  capture_error do
    step %Q(the client successfully gets size of #{mode} "#{path}")
  end
end

When /^the client gets size with no path$/ do
  capture_error do
    client.raw 'SIZE'
  end
end

Then(/^the reported size should be "(.*?)"$/) do |size|
  @size.should eq size.to_i
end
