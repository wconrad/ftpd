# frozen_string_literal: true

def example_args
  @example_args ||= []
end

Given /^the example has argument "(.*?)"$/ do |arg|
  example_args << arg
end

Given /^the example server is started$/ do
  @server = ExampleServer.new(example_args)
end
