Feature: List

  As a client
  I want to list files
  So that I can see what file to transfer

  Scenario: List implicit
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client lists the directory
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: List root
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client lists the directory "/"
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: List subdir
    Given a successful login
    And the server has file "subdir/foo"
    When the client lists the directory "subdir"
    Then the file list should be in long form
    And the file list should contain "foo"

  Scenario: List glob
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    When the client lists the directory "f*"
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should not contain "bar"

  Scenario: Passive
    Given a successful login
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client lists the directory
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: TLS
    pending "TLS not supported in active mode (see README)"

  Scenario: TLS, Passive
    Given a successful login with TLS
    And the server has file "foo"
    And the server has file "bar"
    And the client is in passive mode
    When the client lists the directory
    Then the file list should be in long form
    And the file list should contain "foo"
    And the file list should contain "bar"

  Scenario: Path outside tree
    Given a successful login
    When the client lists the directory ".."
    Then the server returns an access denied error

  Scenario: Missing file
    Given a successful login
    When the client lists the directory "missing/file"
    Then the server returns a no such file error

  Scenario: Not logged in
    Given a successful connection
    When the client lists the directory
    Then the server returns a not logged in error
