require 'date'

Given /^the server has directory "(.*?)"$/ do |remote_path|
  server.add_directory remote_path
end

Given /^the server has file "(.*?)"$/ do |remote_path|
  server.add_file remote_path
end

Given(/^the file "(.*?)" has mtime "(.*?)"$/) do |remote_path, mtime|
  mtime = DateTime.parse(mtime).to_time.utc
  server.set_mtime remote_path, mtime
end

Then /^the server should( not)? have file "(.*?)"$/ do |neg, path|
  matcher = if neg
              :be_false
            else
              :be_true
            end
  server.has_file?(path).should send(matcher)
end

Then /^the server should( not)? have directory "(.*?)"$/ do |neg, path|
  matcher = if neg
              :be_false
            else
              :be_true
            end
  server.has_directory?(path).should send(matcher)
end

Then /^the remote file "(.*?)" should have (unix|windows) line endings$/ do
|remote_path, line_ending_type|
  line_ending_type(server.file_contents(remote_path)).should ==
    line_ending_type.to_sym
end

Then /^the server should have a file with the contents of "(.*?)"$/ do
|path|
  server.has_file_with_contents_of?(path).should be_true
end

Then /^the server should have (\d+) files? with "(.*?)" in the name$/ do
|count, name|
  server.files_named_like(name).size.should == count.to_i
end

Then /^the remote file "(.*?)" should match "(\w+)" \+ "(\w+)"$/ do
|remote_path, template1, template2|
  expected = @server.template(template1) + @server.template(template2)
  actual = @server.file_contents(remote_path)
  actual.should == expected
end

Then /^the remote file "(.*?)" should match "(\w+)"$/ do |remote_path, template|
  expected = @server.template(template)
  actual = @server.file_contents(remote_path)
  actual.should == expected
end
