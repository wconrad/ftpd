Feature: Append

  As a client
  I want to append to a file
  Because it is a log

  Background:
    Given the test server is started

  Scenario: ASCII file with *nix line endings
    Given a successful login
    And the server has file "foo"
    And the client has file "ascii_unix"
    When the client successfully appends text "ascii_unix" onto "foo"
    Then the remote file "foo" should match "foo" + "ascii_unix"

  Scenario: ASCII file with windows line endings
    Given a successful login
    And the server has file "foo"
    And the client has file "ascii_windows"
    When the client successfully appends text "ascii_windows" onto "foo"
    Then the remote file "foo" should match "foo" + "ascii_unix"

  Scenario: Binary file
    Given a successful login
    And the server has file "foo"
    And the client has file "binary"
    When the client successfully appends binary "binary" onto "foo"
    Then the remote file "foo" should match "foo" + "binary"

  Scenario: Passive
    Given a successful login
    And the server has file "foo"
    And the client has file "binary"
    And the client is in passive mode
    When the client successfully appends binary "binary" onto "foo"
    Then the remote file "foo" should match "foo" + "binary"

  Scenario: Destination missing
    Given a successful login
    And the client has file "binary"
    When the client successfully appends binary "binary" onto "foo"
    Then the remote file "foo" should match "binary"

  Scenario: Subdir
    Given a successful login
    And the server has file "subdir/foo"
    And the client has file "binary"
    When the client successfully appends binary "binary" onto "subdir/foo"
    Then the remote file "subdir/foo" should match "foo" + "binary"

  Scenario: Non-root working directory
    Given a successful login
    And the server has file "subdir/foo"
    And the client has file "binary"
    And the client successfully cd's to "subdir"
    When the client successfully appends binary "binary" onto "foo"
    Then the remote file "subdir/foo" should match "foo" + "binary"

  Scenario: Access denied
    Given a successful login
    And the client has file "foo"
    When the client appends binary "foo" onto "forbidden"
    Then the server returns an access denied error

  Scenario: Missing directory
    Given a successful login
    And the client has file "binary"
    When the client appends binary "binary" onto "subdir/foo"
    Then the server returns a not found error

  Scenario: Not logged in
    Given a successful connection
    And the client has file "foo"
    When the client appends binary "foo" onto "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client sends "APPE"
    Then the server returns a syntax error

  Scenario: File system error
    Given a successful login
    And the client has file "foo"
    When the client appends text "foo" onto "unable"
    Then the server returns an action not taken error

  Scenario: Append not enabled
    Given the test server lacks append
    And a successful login
    And the client has file "foo"
    When the client appends text "foo" onto "bar"
    Then the server returns an unimplemented command error
