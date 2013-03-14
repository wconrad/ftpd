Feature: Max Connections

  As an administrator
  I want to limit the number of connections
  To prevent overload

  Scenario: Total connections
    Given the test server has max_connections set to 2
    And the test server is started
    And the 1st client connects
    And the 2nd client connects
    When the 3rd client tries to connect
    Then the server returns a too many connections error

  Scenario: Connections per user
    And the test server has max_connections_per_ip set to 1
    And the test server is started
    And the 1st client connects from 127.0.0.1
    And the 2nd client connects from 127.0.0.2
    When the 3rd client tries to connect from 127.0.0.2
    Then the server returns a too many connections error

  Scenario: TLS
    Given the test server has max_connections set to 2
    And the test server has TLS mode "explicit"
    And the test server is started
    And the 1st client connects
    And the 2nd client connects
    When the 3rd client tries to connect
    Then the server returns a too many connections error

  Scenario: Connections per user, TLS
    And the test server has max_connections_per_ip set to 1
    And the test server has TLS mode "explicit"
    And the test server is started
    And the 1st client connects from 127.0.0.1
    And the 2nd client connects from 127.0.0.2
    When the 3rd client tries to connect from 127.0.0.2
    Then the server returns a too many connections error
