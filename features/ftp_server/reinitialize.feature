Feature: Reinitialize

  As a client
  I want to know this command is not supported
  So that I can avoid using it

  Background:
    Given the test server is started

  Scenario: Unimplemented
    Given a successful connection
    When the client sends command "REIN"
    Then the server returns an unimplemented command error
