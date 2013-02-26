Feature: Make directory

  As a client
  I want to create a directory
  So that I can categorize my uploads

  Background:
    Given the test server is started

  Scenario: Make directory
    Given a successful login
    When the client successfully makes directory "foo"
    Then the server has directory "foo"

  Scenario: Directory of a directory
    Given a successful login
    And the server has directory "foo"
    When the client successfully makes directory "foo/bar"
    Then the server has directory "foo/bar"

  Scenario: Missing directory
    Given a successful login
    When the client makes directory "foo/bar"
    Then the server returns a not found error

  Scenario: After cwd
    Given a successful login
    And the server has directory "foo"
    And the client successfully cd's to "foo"
    When the client successfully makes directory "bar"
    Then the server has directory "foo/bar"

  Scenario: Not logged in
    Given a successful connection
    When the client makes directory "foo"
    Then the server returns a not logged in error

  Scenario: Already exists
    Given a successful login
    And the server has directory "foo"
    When the client makes directory "foo"
    Then the server returns an already exists error

  Scenario: Directory of a file
    Given a successful login
    And the server has file "foo"
    When the client makes directory "foo/bar"
    Then the server returns a not a directory error

  Scenario: Mkdir not enabled
    Given the test server is started without mkdir
    And a successful login
    When the client makes directory "foo"
    Then the server returns an unimplemented command error

  Scenario: Missing path
    Given a successful login
    When the client sends "MKD"
    Then the server returns a syntax error

  Scenario: Access denied
    Given a successful login
    When the client makes directory "forbidden"
    Then the server returns an access denied error

