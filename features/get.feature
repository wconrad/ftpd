Feature: Get

  As a client
  I want to get a file
  So that I have it on my computer

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

  Scenario: TLS
    pending "TLS not supported in active mode (see README)"

  Scenario: TLS, Passive
    Given a successful login with TLS
    And the server has file "ascii_unix"
    And the client is in passive mode
    When the client successfully gets text "ascii_unix"
    Then the local file "ascii_unix" should match the remote file

  Scenario: Path outside tree
    Given a successful login
    When the client gets text "../foo"
    Then the server returns an access denied error

  Scenario: Missing file
    Given a successful login
    When the client gets text "foo"
    Then the server returns a no such file error

  Scenario: Not logged in
    Given a successful connection
    When the client gets text "foo"
    Then the server returns a not logged in error

  Scenario: Missing path
    Given a successful login
    When the client gets with no path
    Then the server returns a syntax error
