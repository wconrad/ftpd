Feature: Command Errors

  As a client
  I want good error messages
  So that I can figure out what went wrong

  Background:
    Given the test server is started

  Scenario: Unknown command
    Given a successful connection
    When the client sends command "foo"
    Then the server returns a command unrecognized error

  Scenario Outline: Unimplemented command
    Given a successful connection
    When the client sends command "<command>"
    Then the server returns an unimplemented command error
    Examples:
      | command |
      | ABOR    |
      | ACCT    |
      | APPE    |
      | HELP    |
      | REIN    |
      | REST    |
      | RNFR    |
      | RNTO    |
      | SITE    |
      | SMNT    |
      | STAT    |
      | STOU    |
