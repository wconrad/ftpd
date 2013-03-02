Feature: Help

  As a client
  I want to ask for help
  So that I can know which commands are supported

  Background:
    Given the test server is started
    And a successful connection

  Scenario: No argument
    When the client successfully asks for help
    Then the server should return a list of commands

  Scenario: Known command
    When the client successfully asks for help for "NOOP"
    Then the server should return help for "NOOP"

  Scenario: Unknown command
    When the client successfully asks for help for "FOO"
    Then the server should return no help for "FOO"
