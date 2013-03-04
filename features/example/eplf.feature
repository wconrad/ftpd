Feature: Example

  As a programmer
  I want to enable EPLF list format
  So that I can test this library with an EPLF client

  Background:
    Given the example has argument "--eplf"
    And the example server is started

  Scenario: List directory
    Given a successful login
    When the client successfully lists the directory
    Then the list should be in EPLF format
