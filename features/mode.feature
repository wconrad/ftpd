Feature: Mode

  As a client
  I want to set the file transfer mode
  So that can optimize the transfer

Scenario: Stream
  Given a successful login
  And the server has file "ascii_unix"
  When the client successfully sets mode "S"
  And the client successfully gets text "ascii_unix"
  Then the remote file "ascii_unix" should match the local file

Scenario: Block
  Given a successful login
  And the server has file "ascii_unix"
  When the client sets mode "B"
  Then the server returns a mode not implemented error

Scenario: Compressed
  Given a successful login
  And the server has file "ascii_unix"
  When the client sets mode "C"
  Then the server returns a mode not implemented error

Scenario: Invalid
  Given a successful login
  And the server has file "ascii_unix"
  When the client sets mode "*"
  Then the server returns an invalid mode error

Scenario: Not logged in
  Given a successful connection
  When the client sets mode "S"
  Then the server returns a not logged in error

Scenario: Missing parameter
  Given a successful login
  When the client sets mode with no parameter
  Then the server returns a syntax error
