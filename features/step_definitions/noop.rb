# frozen_string_literal: true

When /^the( \w+)? client successfully does nothing( with a parameter)?$/ do
|client_name, with_param|
  if with_param
    client(client_name).raw 'NOOP', 'foo'
  else
    client(client_name).noop
  end
end

When /^the( \w+)? client does nothing( with a parameter)?$/ do
|client_name, with_param|
  capture_error do
    step "the#{client_name} client successfully does nothing#{with_param}"
  end
end
