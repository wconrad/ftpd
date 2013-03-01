Feature: Login

  As a client
  I want to log in
  So that I can transfer files

  Background:
    Given the test server is started

  Scenario: Normal connection
    Given a successful login
    Then the server returns no error
    And the client should be logged in

  Scenario: Bad user
    Given the client connects
    When the client logs in with a bad user
    Then the server returns a login incorrect error
    And the client should not be logged in

  Scenario: Bad password
    Given a successful connection
    When the client logs in with a bad password
    Then the server returns a login incorrect error
    And the client should not be logged in

  Scenario: Already logged in
    Given a successful login
    When the client logs in
    Then the server returns a bad sequence error
    And the client should be logged in

  Scenario: PASS when already logged in
    Given a successful login
    When the client sends a password
    Then the server returns a bad sequence error

  Scenario: PASS after failed login
    Given a failed login
    When the client sends a password
    Then the server returns a bad sequence error

  Scenario: PASS without USER
    Given a successful connection
    And the client sends a password
    Then the server returns a bad sequence error

  Scenario: PASS without parameter
    Given a successful connection
    And the client sends a password with no parameter
    Then the server returns a syntax error

  Scenario: USER without parameter
    Given a successful connection
    And the client sends a user with no parameter
    Then the server returns a syntax error

  Scenario: USER not followed by PASS
    Given a successful connection
    And the client sends a user
    When the client sends "NOOP"
    Then the server returns a bad sequence error
