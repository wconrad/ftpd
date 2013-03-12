When /^the client appends (.*)$/ do |args|
  capture_error do
    step "the client successfully appends #{args}"
  end
end

When /^the client successfully appends text "(.*?)" onto "(.*?)"$/ do
|local_path, remote_path|
  client.append_text local_path, remote_path
end

When /^the client successfully appends binary "(.*?)" onto "(.*?)"$/ do
|local_path, remote_path|
  client.append_binary local_path, remote_path
end
