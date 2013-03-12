When /^the client deletes "(.*?)"$/ do |path|
  capture_error do
    step %Q(the client successfully deletes "#{path}")
  end
end

When /^the client successfully deletes "(.*?)"$/ do |path|
  client.delete path
end

When /^the client deletes with no path$/ do
  capture_error do
    client.raw 'DELE'
  end
end
