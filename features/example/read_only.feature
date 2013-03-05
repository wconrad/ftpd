Feature: Example

  As a programmer
  I want to start a read-only server
  So that nobody can modify the file system I expose

  Background:
    Given the example has argument "--read-only"
    And the example server is started

  Scenario: Fetch README
    Given a successful login
    When the client successfully gets text "README"
    Then the local file "README" should match the remote file

  Scenario: Fetch README
    Given a successful login
    When the client successfully gets text "README"
    Then the local file "README" should match the remote file

  Scenario: List
    Given a successful login
    When the client successfully lists the directory
    Then the file list should be in long form
    And the file list should contain "README"

  Scenario: Name List
    Given a successful login
    When the client successfully name-lists the directory
    Then the file list should be in short form
    And the file list should contain "README"

  Scenario: Put
    Given a successful login
    And the client has file "foo"
    When the client puts text "foo"
    Then the server returns an unimplemented command error

  Scenario: Put unique
    Given a successful login
    And the client has file "foo"
    When the client stores unique "foo"
    Then the server returns an unimplemented command error

  Scenario: Delete
    Given a successful login
    When the client deletes "README"
    Then the server returns an unimplemented command error

  Scenario: Mkdir
    Given a successful login
    When the client makes directory "foo"
    Then the server returns an unimplemented command error

  Scenario: Rename
    Given a successful login
    When the client renames "README" to "foo"
    Then the server returns an unimplemented command error

  Scenario: Rmdir
    Given a successful login
    When the client removes directory "foo"
    Then the server returns an unimplemented command error
