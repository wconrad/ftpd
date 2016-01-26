# frozen_string_literal: true

When /^the client sends command "(.*?)"$/ do |command|
  capture_error do
    client.raw command
  end
end
