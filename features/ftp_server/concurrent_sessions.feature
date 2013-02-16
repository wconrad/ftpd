Feature: Mode

  As a client
  I want to start a session when there is another session
  So that my session doesn't have to wait on the other

  Background:
    Given the test server is started

  Scenario: Stream
    Given a successful login
    And the server has file "ascii_unix"
    And the second client connects and logs in
    Then the second client successfully does nothing
