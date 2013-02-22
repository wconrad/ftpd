Feature: Debug

  As a client
  I want to see debug output
  So that I can fix FTP protocol problems

  Scenario: Debug enabled
    Given the test server is started with debug
    And a successful login
    Then the server should have written debug output

  Scenario: Debug disabled
    Given the test server is started
    And a successful login
    Then the server should have written no debug output
