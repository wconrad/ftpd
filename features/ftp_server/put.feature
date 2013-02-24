Feature: Put

  As a client
  I want to securely put a file
  So that someone else can have it
  But nobody else can

  Background:
    Given the test server is started

  Scenario: ASCII file with *nix line endings
    Given a successful login
    And the client has file "ascii_unix"
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file
    And the remote file "ascii_unix" should have unix line endings

  Scenario: ASCII file with windows line endings
    Given a successful login
    And the client has file "ascii_windows"
    When the client successfully puts text "ascii_windows"
    Then the remote file "ascii_windows" should match the local file
    And the remote file "ascii_windows" should have unix line endings

  Scenario: Binary file
    Given a successful login
    And the client has file "binary"
    When the client successfully puts binary "binary"
    Then the remote file "binary" should exactly match the local file

  Scenario: Passive
    Given a successful login
    And the client has file "ascii_unix"
    And the client is in passive mode
    When the client successfully puts text "ascii_unix"
    Then the remote file "ascii_unix" should match the local file

  Scenario: Non-root working directory
    Given a successful login
    And the client has file "ascii_unix"
    And the server has directory "foo"
    And the client successfully cd's to "foo"
    When the client successfully puts text "ascii_unix"
    Then the remote file "foo/ascii_unix" should match the local file

  Scenario: Access denied
    Given a successful login
    And the client has file "forbidden"
    When the client puts text "forbidden"
    Then the server returns an access denied error

  Scenario: Missing directory
    Given a successful login
    And the client has file "bar"
    When the client puts text "foo/bar"
    Then the server returns a no such file error

  Scenario: Not logged in
    Given a successful connection
    And the client has file "foo"
    When the client puts text "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client puts with no path
    Then the server returns a syntax error

  Scenario: File system error
    Given a successful login
    And the client has file "unable"
    When the client puts text "unable"
    Then the server returns an action not taken error

  Scenario: Write not enabled
    Given the test server is started without write
    And a successful login
    And the client has file "foo"
    When the client puts text "foo"
    Then the server returns an unimplemented command error
