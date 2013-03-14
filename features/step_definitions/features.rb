When /^the client successfully requests features$/ do
  @feature_reply = client.raw "FEAT"
end

def feature_regexp(feature)
  /^ #{feature}$/
end

Then /^the response should include feature "(.*?)"$/ do |feature|
  @feature_reply.should =~ feature_regexp(feature)
end

Then /^the response should not include feature "(.*?)"$/ do |feature|
  @feature_reply.should_not =~ feature_regexp(feature)
end

Then /^the response should( not)? include TLS features$/ do |neg|
  step %Q'the response should#{neg} include feature "AUTH TLS"'
  step %Q'the response should#{neg} include feature "PBSZ"'
  step %Q'the response should#{neg} include feature "PROT"'
end
