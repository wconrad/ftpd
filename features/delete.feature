Feature: Delete

  As a client
  I want to delete files
  So that nobody can fetch them from the server

  Scenario: Delete a file
    Given a successful login
    And the server has file "foo"
    When the client successfully deletes "foo"
    Then the server should not have file "foo"

  Scenario: Missing path
    Given a successful login
    And the server has file "foo"
    When the client deletes with no path
    Then the server returns a path required error

  Scenario: No such file
    Given a successful login
    When the client deletes "foo"
    Then the server returns a not found error

  Scenario: Access denied
    Given a successful login
    When the client deletes "forbidden"
    Then the server returns an access denied error

  Scenario: Not logged in
    Given a successful connection
    When the client deletes "foo"
    Then the server returns a not logged in error
