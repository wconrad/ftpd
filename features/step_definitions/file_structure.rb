# frozen_string_literal: true

When /^the client successfully sets file structure "(.*?)"$/ do
|file_structure|
  client.raw 'STRU', file_structure
end

When /^the client sets file structure "(.*?)"$/ do |file_structure|
  capture_error do
    step %Q'the client successfully sets file structure "#{file_structure}"'
  end
end

When /^the client sets file structure with no parameter$/ do
  capture_error do
    client.raw 'STRU'
  end
end
