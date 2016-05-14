Feature: PASV

  As a programmer
  I want good error messages
  So that I can correct problems

  Scenario: No argument
    Given the test server is started
    Given a successful login
    Then the client successfully sends "PASV"

  Scenario: After "EPSV ALL"
    Given the test server is started
    Given a successful login
    Given the client successfully sends "EPSV ALL"
    When the client sends "PASV"
    Then the server sends a not allowed after epsv all error

  Scenario: Not logged in
    Given the test server is started
    Given a successful connection
    When the client sends "EPSV"
    Then the server returns a not logged in error

  Scenario: Configured with NAT IP
    Given the test server has a NAT IP of 10.1.2.3
    Given the test server is started
    And a successful login
    When the client successfully sends "PASV"
    Then the server advertises passive IP 10.1.2.3
