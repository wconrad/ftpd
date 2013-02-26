Feature: Name List TLS

  As a client
  I want to securely list file names
  So that I can see what file to transfer
  And nobody else can

  Background:
    Given the test server is started with explicit TLS

  Scenario: TLS
    pending "TLS not supported in active mode (see README)"

  Scenario: TLS, Passive
    Given a successful login with explicit TLS
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client successfully name-lists the directory
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"
