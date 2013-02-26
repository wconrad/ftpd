Feature: Change Directory

  As a client
  I want to change the current directory
  So that I can use shorter paths

  Background:
    Given the test server is started

  Scenario: Down to subdir
    Given a successful login
    And the server has file "subdir/bar"
    When the client successfully cd's to "subdir"
    Then the current directory should be "/subdir"

  Scenario: Up from subdir
    Given a successful login
    And the server has file "subdir/bar"
    And the client successfully cd's to "subdir"
    When the client successfully cd's to ".."
    Then the current directory should be "/"

  Scenario: Up from root
    Given a successful login
    When the client successfully cd's to ".."
    Then the current directory should be "/"

  Scenario: Change to file
    Given a successful login
    And the server has file "baz"
    When the client cd's to "baz"
    Then the server returns a not a directory error

  Scenario: No such directory
    Given a successful login
    When the client cd's to "subdir"
    Then the server returns a not found error

  Scenario: Access denied
    Given a successful login
    When the client cd's to "forbidden"
    Then the server returns an access denied error

  Scenario: Not logged in
    Given a successful connection
    When the client cd's to "subdir"
    Then the server returns a not logged in error
