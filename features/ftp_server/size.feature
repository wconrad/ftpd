Feature: Size

  As a client
  I want to know the size of a file
  So that I can tell how long it will take to get it

  Background:
    Given the test server is started

  Scenario: ASCII file with *nix line endings
    Given a successful login
    And the server has file "ascii_unix"
    When the client successfully gets size of text "ascii_unix"
    Then the reported size should be "83"

  Scenario: ASCII file with windows line endings
    Given a successful login
    And the server has file "ascii_windows"
    When the client successfully gets size of text "ascii_windows"
    Then the reported size should be "83"

  Scenario: Binary file
    Given a successful login
    And the server has file "binary"
    When the client successfully gets size of binary "binary"
    Then the reported size should be "256"

  Scenario: File in subdirectory
    Given a successful login
    And the server has file "foo/ascii_unix"
    Then the client successfully gets size of text "foo/ascii_unix"

  Scenario: Non-root working directory
    Given a successful login
    And the server has file "foo/ascii_unix"
    And the client successfully cd's to "foo"
    Then the client successfully gets size of text "ascii_unix"

  Scenario: Access denied
    Given a successful login
    When the client gets size of text "forbidden"
    Then the server returns an access denied error

  Scenario: Missing file
    Given a successful login
    When the client gets size of text "foo"
    Then the server returns a not found error

  Scenario: Not logged in
    Given a successful connection
    When the client gets size of text "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client gets size with no path
    Then the server returns a syntax error

  Scenario: File system error
    Given a successful login
    When the client gets size of text "unable"
    Then the server returns an action not taken error

  Scenario: Read not enabled
    Given the test server lacks read
    And a successful login
    And the server has file "foo"
    When the client gets size of text "foo"
    Then the server returns an unimplemented command error
