# frozen_string_literal: true

Given /^the client has file "(.*?)"$/ do |local_path|
  client.add_file local_path
end

Then /^the local file "(.*?)" should have (unix|windows) line endings$/ do
|local_path, line_ending_type|
  expect(line_ending_type(client.file_contents(local_path))).to eq \
  line_ending_type.to_sym
end

Then /^the local file "(.*?)" should match its template$/ do |local_path|
  expect(client.template(local_path)).to eq \
  client.file_contents(local_path)
end
