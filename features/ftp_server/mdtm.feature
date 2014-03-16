Feature: MDTM

  As a client
  I want to get a file's modification time
  So that I can detect when it changes

  Background:
    Given the test server is started

  Scenario: File in current directory
    Given a successful login
    And the server has file "ascii_unix"
    And the file "ascii_unix" has mtime "2014-01-02 13:14:15.123456"
    When the client successfully gets mtime of "ascii_unix"
    Then the reported mtime should be "20140102131415"

  Scenario: File in subdirectory
    Given a successful login
    And the server has file "foo/ascii_unix"
    Then the client successfully gets mtime of "foo/ascii_unix"

  Scenario: Non-root working directory
    Given a successful login
    And the server has file "foo/ascii_unix"
    And the client successfully cd's to "foo"
    Then the client successfully gets mtime of "ascii_unix"

  Scenario: Access denied
    Given a successful login
    When the client gets mtime of "forbidden"
    Then the server returns an access denied error

  Scenario: Missing file
    Given a successful login
    When the client gets mtime of "foo"
    Then the server returns a not found error

  Scenario: Not logged in
    Given a successful connection
    When the client gets mtime of "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client gets mtime with no path
    Then the server returns a syntax error

  Scenario: List not enabled
    Given the test server lacks list
    And a successful login
    And the server has file "foo"
    When the client gets mtime of "foo"
    Then the server returns an unimplemented command error
