Given /^the server has file "(.*?)"$/ do |remote_path|
  @server.add_file remote_path
end

Then /^the server should( not)? have file "(.*?)"$/ do |neg, path|
  matcher = if neg
              :be_false
            else
              :be_true
            end
  @server.has_file?(path).should send(matcher)
end

Then /^the remote file "(.*?)" should have (unix|windows) line endings$/ do
|remote_path, line_ending_type|
  line_ending_type(@server.file_contents(remote_path)).should ==
    line_ending_type.to_sym
end
