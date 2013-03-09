Then /^the server should have written( no)? log output$/ do |neg|
  method = if neg
             :should
           else
             :should_not
           end
  server.log_output.send(method) == ''
end
