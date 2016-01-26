# frozen_string_literal: true

When /^the client renames "(.*?)" to "(.*?)"$/ do
|from_path, to_path|
  capture_error do
    step %Q'the client successfully renames "#{from_path}" to "#{to_path}"'
  end
end

When /^the client successfully renames "(.*?)" to "(.*?)"$/ do
|from_path, to_path|
  client.rename(from_path, to_path)
end
