When /^the client successfully sets mode "(.*?)"$/ do |mode|
  client.raw 'MODE', mode
end

When /^the client sets mode "(.*?)"$/ do |mode|
  capture_error do
    step %Q'the client successfully sets mode "#{mode}"'
  end
end

When /^the client sets mode with no parameter$/ do
  capture_error do
    client.raw 'MODE'
  end
end
