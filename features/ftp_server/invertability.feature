Feature: Get

  As a client
  I want a file to be the same when I get it as it was when I put it
  So that I can use the FTP server for storage

  Background:
    Given the test server is started

  Scenario: Binary file
    Given a successful login
    And the client has file "binary"
    When the client successfully puts binary "binary"
    And the client successfully gets binary "binary"
    Then the local file "binary" should match its template
