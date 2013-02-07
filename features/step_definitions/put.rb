When /^the client successfully puts (text|binary) "(.*?)"$/ do
|mode, local_path|
  @client.put mode, local_path
end

When /^the client puts (\S+) "(.*?)"$/ do |mode, path|
  capture_error do
    step %Q(the client successfully puts #{mode} "#{path}")
  end
end

When /^the client puts with no path$/ do
  capture_error do
    @client.raw 'STOR'
  end
end
