When /^the client successfully requests status$/ do
  @response = client.status
end

When /^the client requests status$/ do
  capture_error do
    step 'the client successfully requests status'
  end
end
