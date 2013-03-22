Feature: Put TLS

  As a client
  I want to put a file securely
  So that nobody can intercept it

  Background:
    Given the test server has TLS mode "explicit"
    And the test server is started

  Scenario: Active
    Given a successful login with explicit TLS
    And the client has file "ascii_unix"
    And the client is in active mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file

  Scenario: Passive
    Given a successful login with explicit TLS
    And the client has file "ascii_unix"
    And the client is in passive mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file
