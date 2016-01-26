# frozen_string_literal: true

When /^the client successfully sets option "(.*?)"$/ do |option|
  client.set_option option
end

When /^the client sets option "(.*?)"$/ do |option|
  capture_error do
    step %q'the client successfully sets option "#{option}"'
  end
end
