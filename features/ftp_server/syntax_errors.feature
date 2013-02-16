Feature: Syntax Errors

  As a client
  I want good error messages
  So that I can figure out what went wrong

  Background:
    Given the test server is started

  Scenario: Empty command
    Given a successful connection
    When the client sends an empty command
    Then the server returns a syntax error

  Scenario: Command contains non-word characters
    Given a successful connection
    When the client sends a non-word command
    Then the server returns a syntax error
