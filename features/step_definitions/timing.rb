Before do
  @start_time = Time.now
end

When /^the client is idle for (\S+) seconds$/ do |seconds|
  sleep seconds.to_f
end

Then /^it should take at least (\S+) seconds$/ do |s|
  min_elapsed_time = s.to_f
  elapsed_time = Time.now - @start_time
  expect(elapsed_time).to be >= min_elapsed_time
end

Then /^it should take less than (\S+) seconds$/ do |s|
  max_elapsed_time = s.to_f
  elapsed_time = Time.now - @start_time
  expect(elapsed_time).to be < max_elapsed_time
end
