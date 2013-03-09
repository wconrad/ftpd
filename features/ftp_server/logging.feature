Feature: Logging

  As a programmer
  I want to see logging output
  So that I can fix FTP protocol problems

  Scenario: Logging enabled
    Given the test server has logging enabled
    And the test server is started
    And a successful login
    Then the server should have written log output
