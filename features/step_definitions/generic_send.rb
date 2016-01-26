# frozen_string_literal: true

When /^the client successfully sends "(.*?)"$/ do |command|
  @reply = client.raw command
end

When /^the client sends "(.*?)"$/ do |command|
  capture_error do
    step %Q'the client successfully sends "#{command}"'
  end
end
