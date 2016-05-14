# frozen_string_literal: true

Given /^the client is in (passive|active) mode$/ do |mode|
  client.passive = mode == 'passive'
end

Then(/^the server advertises passive IP (\S+)$/) do |ip|
  quads = @reply.scan(/\d+/)[1..4].join(".")
  expect(quads).to eq ip
end
