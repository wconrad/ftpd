Feature: No Operation

  As a client
  I want to keep the connection alive
  So that I don't have to log in so often

  Background:
    Given the test server is started

  Scenario: NOP
    Given a successful connection
    Then the client successfully does nothing

  Scenario: With a parameter
    Given a successful connection
    When the client does nothing with a parameter
    Then the server returns a syntax error
