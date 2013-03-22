Feature: List TLS

  As a client
  I want to list files
  So that I can see what file to transfer

  Background:
    Given the test server has TLS mode "explicit"
    And the test server is started

  Scenario: Active
    Given a successful login with explicit TLS
    And the server has file "foo"
    And the server has file "bar"
    And the client is in active mode
    When the client successfully lists the directory
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Passive
    Given a successful login with explicit TLS
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client successfully lists the directory
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"
