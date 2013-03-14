When /^the client is idle for (\S+) seconds$/ do |seconds|
  sleep seconds.to_f
end
