Feature: Delay After Failed Login

  As an administrator
  I want to make brute force attacks less efficient
  So that an attacker doesn't gain access

  Scenario: Failed login attempts
    Given the test server has a failed login delay of 0.2 seconds
    And the test server is started
    Given the client connects
    And the client logs in with bad user
    And the client logs in with bad user
    And the client logs in
    Then it should take at least 0.4 seconds

  Scenario: Failed login attempts
    Given the test server has a failed login delay of 0.0 seconds
    And the test server is started
    Given the client connects
    And the client logs in with bad user
    And the client logs in with bad user
    And the client logs in
    Then it should take less than 0.4 seconds
