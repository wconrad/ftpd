Feature: Get IPV6

  As a client
  I want to get a file
  So that I have it on my computer

  Scenario: Active
    Given the test server is bound to "::1"
    And the test server is started
    And a successful login
    And the server has file "ascii_unix"
    And the client is in active mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file

  Scenario: Passive
    Given the test server is bound to "::1"
    And the test server is started
    And a successful login
    And the server has file "ascii_unix"
    And the client is in passive mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file

  Scenario: Active, TLS
    Given the test server is bound to "::1"
    And the test server has TLS mode "explicit"
    And the test server is started
    And a successful login
    And the server has file "ascii_unix"
    And the client is in active mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file

  Scenario: Passive, TLS
    Given the test server is bound to "::1"
    And the test server has TLS mode "explicit"
    And the test server is started
    And a successful login
    And the server has file "ascii_unix"
    And the client is in passive mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file
