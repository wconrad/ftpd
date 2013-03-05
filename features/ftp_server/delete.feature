Feature: Delete

  As a client
  I want to delete files
  So that nobody can fetch them from the server

  Background:
    Given the test server is started

  Scenario: Delete a file
    Given a successful login
    And the server has file "foo"
    When the client successfully deletes "foo"
    Then the server should not have file "foo"

  Scenario: Delete a file in a subdirectory
    Given a successful login
    And the server has file "foo/bar"
    When the client successfully deletes "foo/bar"
    Then the server should not have file "foo/bar"

  Scenario: Change current directory
    Given a successful login
    And the server has file "foo/bar"
    And the client successfully cd's to "foo"
    When the client successfully deletes "bar"
    Then the server should not have file "foo/bar"

  Scenario: Missing path
    Given a successful login
    And the server has file "foo"
    When the client deletes with no path
    Then the server returns a path required error

  Scenario: not found
    Given a successful login
    When the client deletes "foo"
    Then the server returns a not found error

  Scenario: Access denied
    Given a successful login
    When the client deletes "forbidden"
    Then the server returns an access denied error

  Scenario: File system error
    Given a successful login
    When the client deletes "unable"
    Then the server returns an action not taken error

  Scenario: Not logged in
    Given a successful connection
    When the client deletes "foo"
    Then the server returns a not logged in error

  Scenario: Delete not enabled
    Given the test server lacks delete
    And a successful login
    And the server has file "foo"
    When the client deletes "foo"
    Then the server returns an unimplemented command error
