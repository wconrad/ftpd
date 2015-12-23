require_relative "../../testlib/network"

include TestLib::Network

Given /^the stack supports ipv6$/ do
  unless ipv6_supported?
    pending "Test skipped: stack does not support ipv6"
  end
end
