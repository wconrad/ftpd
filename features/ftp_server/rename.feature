Feature: Rename

  As a client
  I want to rename a file
  To correct an improper name

  Background:
    Given the test server is started

  Scenario: Rename
    Given a successful login
    And the server has file "foo"
    When the client successfully renames "foo" to "bar"
    Then the server should not have file "foo"
    And the server should have file "bar"

  Scenario: Move
    Given a successful login
    And the server has file "foo/bar"
    And the server has directory "baz"
    When the client successfully renames "foo/bar" to "baz/qux"
    Then the server should not have file "foo/bar"
    And the server should have file "baz/qux"

  Scenario: Non-root working directory
    Given a successful login
    And the server has file "foo/bar"
    And the client successfully cd's to "foo"
    When the client successfully renames "bar" to "baz"
    Then the server should not have file "foo/bar"
    Then the server should have file "foo/baz"

  Scenario: Access denied (source)
    Given a successful login
    When the client renames "forbidden" to "foo"
    Then the server returns an access denied error

  Scenario: Access denied (destination)
    Given a successful login
    And the server has file "foo"
    When the client renames "foo" to "forbidden"
    Then the server returns an access denied error

  Scenario: Source missing
    Given a successful login
    When the client renames "foo" to "bar"
    Then the server returns a not found error

  Scenario: Destination exists
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client renames "foo" to "bar"
    Then the server returns an already exists error

  Scenario: Not logged in (RNFR)
    Given a successful connection
    When the client sends "RNFR foo"
    Then the server returns a not logged in error

  Scenario: Not logged in (RNTO)
    Given a successful connection
    When the client sends "RNTO foo"
    Then the server returns a not logged in error

  Scenario: Missing path (RNFR)
    Given a successful login
    When the client sends "RNFR"
    Then the server returns a syntax error

  Scenario: Missing path (RNTO)
    Given a successful login
    When the client sends "RNTO"
    Then the server returns a syntax error

  Scenario: Rename not enabled
    Given the test server is started without rename
    And a successful login
    And the server has file "foo"
    When the client renames "foo" to "bar"
    Then the server returns an unimplemented command error
