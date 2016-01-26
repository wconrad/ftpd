# frozen_string_literal: true

Then /^the server should have written( no)? log output$/ do |neg|
  verb = if neg
           :to
         else
           :to_not
         end
  expect(server.log_output).send(verb, eq(''))
end
