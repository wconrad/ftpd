When /^the client cd's to "(.*?)"$/ do |path|
  capture_error do
    step %Q(the client successfully cd's to "#{path}")
  end
end

# As of Ruby 1.9.3-p125, Net::FTP#chdir('..') will send a CDUP.
# However, that could conceivably change: The use of CDUP not
# required by the FTP protocol.  Therefore we use this step to
# ensure that CDUP is sent and therefore tested.

When /^the client successfully cd's up$/ do
  @client.raw 'CDUP'
end

When /^the client successfully cd's to "(.*?)"$/ do |path|
  @client.chdir path
end

Then /^the current directory should be "(.*?)"$/ do |path|
  @client.pwd.should == path
end

Then /^the XPWD directory should be "(.*?)"$/ do |path|
  @client.xpwd.should == path
end
