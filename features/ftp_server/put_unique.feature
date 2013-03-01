Feature: Put Unique

  As a client
  I want to upload a file with a unique name
  So that it will not overwrite an existing file

  Background:
    Given PENDING: unimplemented
    Given the test server is started

  Scenario: File does not exist
    Given a successful login
    And the client has file "foo"
    When the client successfully puts unique "foo"
    Then the server should have a file with the contents of "foo"

  Scenario: Suggest name
    Given a successful login
    And the client has file "foo"
    When the client successfully puts unique "foo" to "bar"
    Then the server should have a file with the contents of "foo"
    And the server should have 1 file with "bar" in the name

  Scenario: Suggested name exists
    Given a successful login
    And the client has file "foo"
    And the server has file "bar"
    When the client successfully puts unique "foo" to "bar"
    Then the server should have a file with the contents of "foo"
    And the server should have 2 files with "bar" in the name
