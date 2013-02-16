Feature: Quit

  As a client
  In order to free up resources
  I want to close the connection

  Background:
    Given the test server is started

  Scenario: Logged in
    Given a successful login
    When the client successfully quits
    Then the client should not be logged in

  Scenario: With a parameter
    Given a successful connection
    When the client quits with a parameter
    Then the server returns a syntax error

  Scenario: Not logged in
    Given a successful connection
    When the client quits
    Then the server returns a not logged in error
