# frozen_string_literal: true

When /^the client successfully quits$/ do
  client.quit
end

When /^the client quits$/ do
  capture_error do
    step 'the client successfully quits'
  end
end

When /^the client quits with a parameter$/ do
  capture_error do
    client.raw 'QUIT', 'foo'
  end
end
