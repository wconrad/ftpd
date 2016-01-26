# frozen_string_literal: true

require 'date'

When /^the client successfully gets mtime of "(.*?)"$/ \
do |remote_path|
  @mtime = client.get_mtime remote_path
end

When /^the client gets mtime of "(.*?)"$/ do |path|
  capture_error do
    step %Q(the client successfully gets mtime of "#{path}")
  end
end

When /^the client gets mtime with no path$/ do
  capture_error do
    client.raw 'MDTM'
  end
end

Then(/^the reported mtime should be "(.*?)"$/) do |mtime|
  expected_time = DateTime.parse(mtime).to_time.utc
  expect(@mtime).to eq expected_time
end
