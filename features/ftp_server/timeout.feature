Feature: Port

  As a programmer
  I want idle sessions to timeout and disconnect
  So that I can claim RFC compliance

  Scenario: Session idle too long
    Given the test server has session timeout set to 0.5 seconds
    And the test server is started
    And a successful login
    When the client is idle for 0.6 seconds
    Then the client should not be connected

  Scenario: Session not idle too long
    Given the test server has session timeout set to 0.5 seconds
    And the test server is started
    And a successful login
    When the client is idle for 0 seconds
    Then the client should be connected

  Scenario: Timeout disabled
    Given the test server has session timeout disabled
    And the test server is started
    And a successful login
    When the client is idle for 0.6 seconds
    Then the client should be connected
