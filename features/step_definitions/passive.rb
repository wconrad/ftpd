Given /^the client is in (passive|active) mode$/ do |mode|
  @client.passive = mode == 'passive'
end
