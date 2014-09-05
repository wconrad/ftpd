Then /^the server returns its title$/ do
  step 'the server returns its name'
  step 'the server returns its version'
end

Then /^the server returns its name$/ do
  expect(@response).to include @server.server_name
end

Then /^the server returns its version$/ do
  expect(@response).to match /\b\d+\.\d+\.\d+\b/
end
