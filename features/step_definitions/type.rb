When /^the client successfully sets type "(.*?)"$/ do |type|
  client.raw 'TYPE', type
end

When /^the client sets type "(.*?)"$/ do |type|
  capture_error do
    step %Q'the client successfully sets type "#{type}"'
  end
end

When /^the client sets type with no parameter$/ do
  capture_error do
    client.raw 'TYPE'
  end
end
