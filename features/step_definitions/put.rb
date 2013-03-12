When /^the client successfully puts (text|binary) "(.*?)"$/ do
|mode, local_path|
  client.put mode, local_path
end

When /^the client puts (\S+) "(.*?)"$/ do |mode, path|
  capture_error do
    step %Q(the client successfully puts #{mode} "#{path}")
  end
end

When /^the client puts with no path$/ do
  capture_error do
    client.raw 'STOR'
  end
end

When /^the client successfully stores unique "(.*?)"(?: to "(.*?)")?$/ do
|local_path, remote_path|
  client.store_unique local_path, remote_path
end

When /^the client stores unique "(.*?)"( to ".*?")?$/ do
|local_path, remote_path|
  capture_error do
    step(%Q'the client successfully stores unique ' +
         %Q'"#{local_path}"#{remote_path}')
  end
end
