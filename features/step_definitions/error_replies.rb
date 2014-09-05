def capture_error
  yield
  @error = nil
rescue Net::FTPError => e
  @error = e.message
end

Then /^the server returns no error$/ do
  expect(@error).to be_nil
end

Then /^the server returns a "(.*?)" error$/ do |error_message|
  expect(@error || '').to include error_message
end

Then /^the server returns a too many connections error$/ do
  step 'the server returns a "421 Too many connections" error'
end

Then /^the server returns a server unavailable error$/ do
  step 'the server returns a "421 server unavailable" error'
end

Then /^the server returns a not a directory error$/ do
  step 'the server returns a "550 Not a directory" error'
end

Then /^the server returns a login incorrect error$/ do
  step 'the server returns a "530 Login incorrect" error'
end

Then /^the server returns a not logged in error$/ do
  step 'the server returns a "530 Not logged in" error'
end

Then /^the server returns an access denied error$/ do
  step 'the server returns a "550 Access denied" error'
end

Then /^the server returns a path required error$/ do
  step 'the server returns a "501 Path required" error'
end

Then /^the server returns a not found error$/ do
  step 'the server returns a "550 No such file or directory" error'
end

Then /^the server returns a syntax error$/ do
  step 'the server returns a "501 Syntax error" error'
end

Then /^the server returns a bad option error$/ do
  step 'the server returns a "501 Unsupported option" error'
end

Then /^the server returns a mode not implemented error$/ do
  step 'the server returns a "504 Mode not implemented" error'
end

Then /^the server returns an invalid mode error$/ do
  step 'the server returns a "504 Invalid mode code" error'
end

Then /^the server returns a file structure not implemented error$/ do
  step 'the server returns a "504 Structure not implemented" error'
end

Then /^the server returns an invalid file structure error$/ do
  step 'the server returns a "504 Invalid structure code" error'
end

Then /^the server returns a bad sequence error$/ do
  step 'the server returns a "503 Bad sequence of commands" error'
end

Then /^the server returns a type not implemented error$/ do
  step 'the server returns a "504 Type not implemented" error'
end

Then /^the server returns an invalid type error$/ do
  step 'the server returns a "504 Invalid type code" error'
end

Then /^the server returns a format not implemented error$/ do
  step 'the server returns a "504 Format not implemented" error'
end

Then /^the server returns an unimplemented parameter error$/ do
  step('the server returns a "504 Command not '\
       'implemented for that parameter" error')
end

Then /^the server returns a command unrecognized error$/ do
  step 'the server returns a "500 Syntax error, command unrecognized" error'
end

Then /^the server returns an unimplemented command error$/ do
  step 'the server returns a "502 Command not implemented" error'
end

Then /^the server returns an action not taken error$/ do
  step 'the server returns a "550 Unable to do it" error'
end

Then /^the server returns an already exists error$/ do
  step 'the server returns a "550 Already exists" error'
end

Then /^the server returns a network protocol not supported error$/ do
  step 'the server returns a "522 Network protocol" error'
end

Then /^the server sends a not allowed after epsv all error$/ do
  step 'the server returns a "501 Not allowed after EPSV ALL" error'
end
