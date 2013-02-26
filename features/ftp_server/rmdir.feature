Feature: Remove directory

  As a client
  I want to remove a directory
  To reduce clutter

  Background:
    Given the test server is started

  Scenario: Make directory
    Given a successful login
    And the server has directory "foo"
    When the client successfully removes directory "foo"
    Then the server should not have directory "foo"

  Scenario: Directory of a directory
    Given a successful login
    And the server has directory "foo/bar"
    When the client successfully removes directory "foo/bar"
    Then the server should not have directory "foo/bar"
    And the server has directory "foo"

  Scenario: Missing directory
    Given a successful login
    When the client removes directory "foo/bar"
    Then the server returns a not found error

  Scenario: After cwd
    Given a successful login
    And the server has directory "foo/bar"
    And the client successfully cd's to "foo"
    When the client successfully removes directory "bar"
    Then the server should not have directory "foo/bar"

  Scenario: Not logged in
    Given a successful connection
    When the client removes directory "foo"
    Then the server returns a not logged in error

  Scenario: Does not exist
    Given a successful login
    When the client removes directory "foo"
    Then the server returns a not found error

  Scenario: Remove a file
    Given a successful login
    And the server has file "foo"
    When the client removes directory "foo"
    Then the server returns a not a directory error

  Scenario: Rmdir not enabled
    Given the test server is started without rmdir
    And a successful login
    When the client removes directory "foo"
    Then the server returns an unimplemented command error

  Scenario: Missing path
    Given a successful login
    When the client sends "RMD"
    Then the server returns a syntax error

  Scenario: Access denied
    Given a successful login
    When the client removes directory "forbidden"
    Then the server returns an access denied error
