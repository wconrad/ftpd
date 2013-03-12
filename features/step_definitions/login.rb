def logged_in?
  step "the client lists the directory"
  @error.nil?
end

def login(tokens, client_name = nil)
  capture_error do
    client(client_name).login *tokens
  end
end

Given /^a successful connection( with \w+ TLS)?$/ do |with_tls|
  step "the client connects#{with_tls}"
end

Given /^a successful login( with \w+ TLS)?$/ do |with_tls|
  step "a successful connection#{with_tls}"
  step 'the client logs in'
end

Given /^a failed login$/ do
  step 'the client connects'
  step 'the client logs in with bad user'
end

When /^the(?: (\w+))? client logs in(?: with bad (\w+))?$/ do
|client_name, bad|
  tokens = [
    if bad == 'user'
      'bad_user'
    else
      @server.user
    end,
    if bad == 'password'
      'bad_password'
    else
      @server.password
    end,
    if bad == 'account'
      'bad_account'
    else
      @server.account
    end,
  ][0..server.auth_level]
  login(tokens, client_name)
end

Then /^the client should( not)? be logged in$/ do |neg|
  matcher_method = if neg
                     :be_false
                   else
                     :be_true
                   end
  logged_in?.should send(matcher_method)
end

When /^the client sends a password( with no parameter)?$/ do |no_param|
  capture_error do
    args = if no_param
             []
           else
             [server.password]
           end
    client.raw 'PASS', *args
  end
end

When /^the client sends a user( with no parameter)?$/ do |no_param|
  capture_error do
    args = if no_param
             []
           else
             [server.user]
           end
    client.raw 'USER', *args
  end
end

Given /^the (\w+) client connects and logs in$/ do |client_name|
  step "the #{client_name} client connects"
  step "the #{client_name} client logs in"
end
