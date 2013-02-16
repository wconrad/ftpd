Feature: Example

  As a programmer
  I want to connect to the example
  So that I can try this libary with an arbitrary FTP client

  Background:
    Given the example server is started

  Scenario: Normal connection
    Given a successful login
    Then the server returns no error
    And the client should be logged in

  Scenario: Fetch README
    Given a successful login
    When the client successfully gets text "README"
    Then the local file "README" should match the remote file
