Feature: Put Unique

  As a client
  I want to upload a file with a unique name
  So that it will not overwrite an existing file

  Background:
    Given the test server is started

  Scenario: File does not exist
    Given a successful login
    And the client has file "foo"
    When the client successfully stores unique "foo"
    Then the server should have a file with the contents of "foo"

  Scenario: Suggest name
    Given a successful login
    And the client has file "foo"
    When the client successfully stores unique "foo" to "bar"
    Then the server should have a file with the contents of "foo"
    And the server should have 1 file with "bar" in the name

  Scenario: Suggested name exists
    Given a successful login
    And the client has file "foo"
    And the server has file "bar"
    When the client successfully stores unique "foo" to "bar"
    Then the server should have a file with the contents of "foo"
    Then the server should have a file with the contents of "bar"
    And the server should have 2 files with "bar" in the name

  Scenario: Non-root working directory
    Given a successful login
    And the client has file "bar"
    And the server has directory "foo"
    And the client successfully cd's to "foo"
    When the client successfully stores unique "bar" to "bar"
    Then the remote file "foo/bar" should match the local file

  Scenario: Missing directory
    Given a successful login
    And the client has file "bar"
    When the client stores unique "bar" to "foo/bar"
    Then the server returns a not found error

  Scenario: Not logged in
    Given a successful connection
    When the client sends "STOU"
    Then the server returns a not logged in error

  Scenario: Write not enabled
    Given the test server lacks write
    And a successful login
    And the client has file "foo"
    When the client stores unique "foo"
    Then the server returns an unimplemented command error
