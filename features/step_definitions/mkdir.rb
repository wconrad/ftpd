When /^the client makes directory "(.*?)"$/ do |path|
  capture_error do
    step %Q(the client successfully makes directory "#{path}")
  end
end

When /^the client successfully makes directory "(.*?)"$/ do |path|
  mkdir_response = @client.mkdir path
end
