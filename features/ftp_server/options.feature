Feature: Options

  As a client
  I want to know set options
  To tailor the server's behavior

  Background:
    Given the test server is started
    And the client connects

  Scenario: No argument
    When the client sends "OPTS"
    Then the server returns a syntax error

  Scenario: Unknown option command
    When the client sets option "ABC"
    Then the server returns a bad option error
