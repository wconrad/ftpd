Feature: Name List

  As a client
  I want to list file names
  So that I can see what file to transfer

  Scenario: Implicit
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client successfully name-lists the directory
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Root
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client successfully name-lists the directory "/"
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Parent of root
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client successfully name-lists the directory "/.."
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Subdir
    Given a successful login
    And the server has file "subdir/foo"
    When the client successfully name-lists the directory "subdir"
    Then the file list should be in short form
    And the file list should contain "foo"

  Scenario: Glob
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client successfully name-lists the directory "f*"
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should not contain "bar"

  Scenario: Passive
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client successfully name-lists the directory
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: TLS
    pending "TLS not supported in active mode (see README)"

  Scenario: TLS, Passive
    Given a successful login with TLS
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client successfully name-lists the directory
    Then the file list should be in short form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Missing directory
    Given a successful login
    When the client successfully name-lists the directory "missing/file"
    Then the file list should be empty

  Scenario: Not logged in
    Given a successful connection
    When the client name-lists the directory
    Then the server returns a not logged in error
