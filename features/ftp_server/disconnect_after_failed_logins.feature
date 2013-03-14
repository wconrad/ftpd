Feature: Disconnect After Failed Logins

  As an administrator
  I want to make brute force attacks less efficient
  So that an attacker doesn't gain access

  Scenario: Disconnected after maximum failed attempts
    Given the test server has a max of 3 failed login attempts
    And the test server is started
    Given the client connects
    And the client logs in with bad user
    And the client logs in with bad user
    When the client logs in with bad user
    Then the server returns a server unavailable error
    And the client should not be connected

  Scenario: No maximum configured
    Given the test server has no max failed login attempts
    And the test server is started
    Given the client connects
    And the client logs in with bad user
    And the client logs in with bad user
    And the client logs in with bad user
    Then the server returns a login incorrect error
    And the client should be connected
