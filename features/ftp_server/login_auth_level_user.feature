Feature: Login

  As a client
  I want to log in
  So that I can transfer files

  Background:
    Given the test server has auth level "AUTH_USER"
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

  Scenario: Already logged in
    Given a successful login
    When the client logs in
    Then the server returns a bad sequence error
    And the client should be logged in

  Scenario: USER without parameter
    Given a successful connection
    And the client sends a user with no parameter
    Then the server returns a syntax error
