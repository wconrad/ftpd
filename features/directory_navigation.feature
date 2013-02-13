Feature: Change Directory

  As a client
  I want to change the current directory
  So that I can use shorter paths

  Scenario: Change to subdirectory
    Given a successful login
    And the server has file "subdir/bar"
    When the client successfully cd's to "subdir"
    Then the current directory should be "/subdir"

  Scenario: Change to parent from subdir
    Given a successful login
    And the server has file "subdir/bar"
    And the client successfully cd's to "subdir"
    When the client successfully cd's up
    Then the current directory should be "/"

  Scenario: Change to parent from root
    Given a successful login
    When the client successfully cd's up
    Then the current directory should be "/"

  Scenario: Change to file
    Given a successful login
    And the server has file "baz"
    When the client cd's to "baz"
    Then the server returns a not a directory error

  Scenario: No such directory
    Given a successful login
    When the client cd's to "subdir"
    Then the server returns a no such file error

  Scenario: Access denied
    Given a successful login
    When the client cd's to "forbidden"
    Then the server returns an access denied error

  Scenario: Not logged in
    Given a successful connection
    When the client cd's to "subdir"
    Then the server returns a not logged in error
