When /^the client sends an empty command$/ do
  capture_error do
    client.raw ''
  end
end

When /^the client sends a non-word command$/ do
  capture_error do
    client.raw '*'
  end
end
