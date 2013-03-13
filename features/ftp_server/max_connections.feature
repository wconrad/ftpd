Feature: Concurrent Sessions

  As an administrator
  I want to limit the number of connections
  To prevent overload

  Background:
    Given the test server has max_connections set to 2
    And the test server is started

  Scenario: Stream
    Given the 1st client connects
    And the 2nd client connects
    When the 3rd client tries to connect
    Then the server returns a too many connections error
