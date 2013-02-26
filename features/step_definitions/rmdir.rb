When /^the client removes directory "(.*?)"$/ do |path|
  capture_error do
    step %Q(the client successfully removes directory "#{path}")
  end
end

When /^the client successfully removes directory "(.*?)"$/ do |path|
  mkdir_response = @client.rmdir path
end
