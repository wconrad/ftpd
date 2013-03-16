Feature: Status

  As a client
  I want server status
  To know what state the server is in

  Background:
    Given the test server is started

  Scenario: Not logged in
    Given a successful connection
    When the client requests status
    Then the server returns a not logged in error

  Scenario: Server status
    Given a successful login
    When the client successfully requests status
    Then the server returns its title
