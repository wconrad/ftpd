Then /^the server should have written( no)? debug output$/ do |neg|
  method = if neg
             :should
           else
             :should_not
           end
  server.debug_output.send(method) == ''
end
