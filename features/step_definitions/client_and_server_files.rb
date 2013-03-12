def unix_line_endings(exactly, s)
  return s if exactly
  s.gsub(/\r\n/, "\n")
end

Then /^the remote file "(.*?)" should( exactly)? match the local file$/ do
|remote_path, exactly|
  local_path = File.basename(remote_path)
  remote_contents = server.file_contents(remote_path)
  local_contents = client.file_contents(local_path)
  remote_contents = unix_line_endings(exactly, remote_contents)
  local_contents = unix_line_endings(exactly, local_contents)
  remote_contents.should == local_contents
end

Then /^the local file "(.*?)" should( exactly)? match the remote file$/ do
|local_path, exactly|
  remote_path = local_path
  remote_contents = server.file_contents(remote_path)
  local_contents = client.file_contents(local_path)
  remote_contents = unix_line_endings(exactly, remote_contents)
  local_contents = unix_line_endings(exactly, local_contents)
  local_contents.should == remote_contents
end
