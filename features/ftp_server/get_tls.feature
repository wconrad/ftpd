Feature: Get TLS

  As a client
  I want to get a file
  So that I have it on my computer

  Background:
    Given the test server is started with TLS

  Scenario: TLS
    pending "TLS not supported in active mode (see README)"

  Scenario: TLS, Passive
    Given a successful login with TLS
    And the server has file "ascii_unix"
    And the client is in passive mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file
