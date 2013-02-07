When /^the client successfully does nothing( with a parameter)?$/ do |with_param|
  if with_param
    @client.raw 'NOOP', 'foo'
  else
    @client.noop
  end
end

When /^the client does nothing( with a parameter)?$/ do |with_param|
  capture_error do
    step "the client successfully does nothing#{with_param}"
  end
end
