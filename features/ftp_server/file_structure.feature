Feature: File Structure

  As a server
  I want to accept the obsolute file structure (STRU) command
  For compatability

  Background:
    Given the test server is started

  Scenario: File
  Given a successful login
  And the server has file "ascii_unix"
  When the client successfully sets file structure "F"
  And the client successfully gets text "ascii_unix"
  Then the remote file "ascii_unix" should match the local file

  Scenario: Record
    Given a successful login
    And the server has file "ascii_unix"
    When the client sets file structure "R"
    Then the server returns a file structure not implemented error

  Scenario: Page
    Given a successful login
    And the server has file "ascii_unix"
    When the client sets file structure "P"
    Then the server returns a file structure not implemented error

  Scenario: Invalid
    Given a successful login
    And the server has file "ascii_unix"
    When the client sets file structure "*"
    Then the server returns an invalid file structure error

  Scenario: Not logged in
    Given a successful connection
    When the client sets file structure "F"
    Then the server returns a not logged in error

  Scenario: Missing parameter
    Given a successful login
    When the client sets file structure with no parameter
    Then the server returns a syntax error
