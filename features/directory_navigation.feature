Feature: Change Directory

  As a client
  I want to change the current directory
  So that I can use shorter paths

  Scenario: Change to subdirectory
    Given a successful login
    And the server has file "subdir/bar"
    When the client successfully cd's to "subdir"
    Then the current directory should be "/subdir"

  Scenario: Change to parent
    Given a successful login
    And the server has file "subdir/bar"
    And the server has file "baz"
    And the client successfully cd's to "subdir"
    When the client successfully cd's up
    Then the current directory should be "/"

  Scenario: No such directory
    Given a successful login
    When the client cd's to "subdir"
    Then the server returns a no such file error

  Scenario: Path outside tree
    Given a successful login
    When the client cd's to "../usr/bin"
    Then the server returns an access denied error

  Scenario: Not logged in
    Given a successful connection
    When the client cd's to "subdir"
    Then the server returns a not logged in error
