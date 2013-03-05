Feature: Login

  As a client
  I want to log in
  So that I can transfer files

  Background:
    Given the test server has auth level "AUTH_ACCOUNT"
    And the test server is started

  Scenario: Normal connection
    Given a successful login
    Then the server returns no error
    And the client should be logged in

  Scenario: Bad user
    Given the client connects
    When the client logs in with bad user
    Then the server returns a login incorrect error
    And the client should not be logged in

  Scenario: Bad password
    Given a successful connection
    When the client logs in with bad password
    Then the server returns a login incorrect error
    And the client should not be logged in

  Scenario: Bad account
    Given a successful connection
    When the client logs in with bad account
    Then the server returns a login incorrect error
    And the client should not be logged in

  Scenario: ACCT without parameter
    Given a successful connection
    And the client sends a user
    And the client sends a password
    When the client sends "ACCT"
    Then the server returns a syntax error

  Scenario: PASS not followed by ACCT
    Given a successful connection
    And the client sends a user
    And the client sends a password
    When the client sends "NOOP"
    Then the server returns a bad sequence error

  Scenario: ACCT out of sequence
    Given a successful connection
    When the client sends "ACCT"
    Then the server returns a bad sequence error
