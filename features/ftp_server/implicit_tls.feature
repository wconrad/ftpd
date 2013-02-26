Feature: Put TLS

  As a server
  I want to use implicit TLS
  Because I must serve out-of-date clients

  Background:
    Given the test server is started with implicit TLS

  Scenario: Get
    pending "TLS not supported in active mode (see README)"

  Scenario: Get (passive)
    Given a successful login with implicit TLS
    And the client has file "ascii_unix"
    And the client is in passive mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file
