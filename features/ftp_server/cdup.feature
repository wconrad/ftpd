Feature: Change Directory

  As a client
  I want to change to the parent directory

  Background:
    Given the test server is started

  Scenario: From subdir
    Given a successful login
    And the server has directory "subdir"
    And the client successfully cd's to "subdir"
    When the client successfully cd's up
    Then the current directory should be "/"

  Scenario: From root
    Given a successful login
    When the client successfully cd's up
    Then the current directory should be "/"

  Scenario: XCUP
    Given a successful login
    And the server has directory "subdir"
    And the client successfully cd's to "subdir"
    When the client successfully sends "XCUP"
    Then the current directory should be "/"

  Scenario: With argument
    Given a successful login
    When the client sends "CDUP abc"
    Then the server returns a syntax error

  Scenario: Not logged in
    Given a successful connection
    When the client cd's to "subdir"
    Then the server returns a not logged in error
