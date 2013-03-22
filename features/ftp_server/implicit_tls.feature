Feature: Implicit TLS

  As a server
  I want to use implicit TLS
  Because I must serve out-of-date clients

  Background:
    Given the test server has TLS mode "implicit"
    And the test server is started

  Scenario: Active
    Given a successful login with implicit TLS
    And the client has file "ascii_unix"
    And the client is in active mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file

  Scenario: Passive
    Given a successful login with implicit TLS
    And the client has file "ascii_unix"
    And the client is in passive mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file
