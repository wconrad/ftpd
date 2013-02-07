When /^the client successfully gets (text|binary) "(.*?)"$/ \
do |mode, remote_path|
  @client.get mode, remote_path
end

When /^the client gets (\S+) "(.*?)"$/ do |mode, path|
  capture_error do
    step %Q(the client successfully gets #{mode} "#{path}")
  end
end

When /^the client gets with no path$/ do
  capture_error do
    @client.raw 'RETR'
  end
end
