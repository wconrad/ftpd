Then /^the server returns a "(.*?)" reply$/ do |reply|
  @reply.should == reply + "\n"
end

Then /^the server returns a not necessary reply$/ do
  step 'the server returns a "202 Command not needed at this site" reply'
end
