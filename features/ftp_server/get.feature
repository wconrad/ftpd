Feature: Get

  As a client
  I want to securely get a file
  So that I have it on my computer
  But nobody else can

  Background:
    Given the test server is started

  Scenario: ASCII file with *nix line endings
    Given a successful login
    And the server has file "ascii_unix"
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file
    And the local file "ascii_unix" should have unix line endings

  Scenario: ASCII file with windows line endings
    Given a successful login
    And the server has file "ascii_windows"
    When the client successfully gets text "ascii_windows"
    Then the local file "ascii_windows" should match the remote file
    And the local file "ascii_windows" should have unix line endings

  Scenario: Binary file
    Given a successful login
    And the server has file "binary"
    When the client successfully gets binary "binary"
    Then the local file "binary" should exactly match the remote file

  Scenario: Passive
    Given a successful login
    And the server has file "ascii_unix"
    And the client is in passive mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file

  Scenario: File in subdirectory
    Given a successful login
    And the server has file "foo/ascii_unix"
    Then the client successfully gets text "foo/ascii_unix"

  Scenario: Non-root working directory
    Given a successful login
    And the server has file "foo/ascii_unix"
    And the client successfully cd's to "foo"
    When the client successfully gets text "ascii_unix"
    Then the remote file "foo/ascii_unix" should match the local file

  Scenario: Access denied
    Given a successful login
    When the client gets text "forbidden"
    Then the server returns an access denied error

  Scenario: Missing file
    Given a successful login
    When the client gets text "foo"
    Then the server returns a not found error

  Scenario: Not logged in
    Given a successful connection
    When the client gets text "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client gets with no path
    Then the server returns a syntax error

  Scenario: File system error
    Given a successful login
    When the client gets text "unable"
    Then the server returns an action not taken error

  Scenario: Read not enabled
    Given the test server lacks read
    And a successful login
    And the server has file "foo"
    When the client gets text "foo"
    Then the server returns an unimplemented command error
