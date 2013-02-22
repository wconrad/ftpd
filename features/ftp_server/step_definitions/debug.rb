Then /^the server should have written( no)? debug output$/ do |neg|
  matcher = if neg
              be_false
            else
              be_true
            end
  @server.wrote_debug_output?.should matcher
end
