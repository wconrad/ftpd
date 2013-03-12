Given /^the client has file "(.*?)"$/ do |local_path|
  client.add_file local_path
end

Then /^the local file "(.*?)" should have (unix|windows) line endings$/ do
|local_path, line_ending_type|
  line_ending_type(client.file_contents(local_path)).should ==
    line_ending_type.to_sym
end

Then /^the local file "(.*?)" should match its template$/ do |local_path|
  client.template(local_path).should ==
    client.file_contents(local_path)
end
