Feature: EPRT

  As a programmer
  I want good error messages
  So that I can correct problems

  Background:
    Given the test server is bound to "::"
    Given the test server is started

  Scenario: Port 1024
    Given a successful login
    Then the client successfully sends "EPRT |1|1.2.3.4|1024|"

  Scenario: Port 1023; low ports disallowed
    Given the test server disallows low data ports
    And a successful login
    When the client sends "EPRT |1|2.3.4.3|255|"
    Then the server returns an unimplemented parameter error

  Scenario: Port out of range
    Given a successful login
    When the client sends "EPRT |1|2.3.4.5|65536|"
    Then the server returns an unimplemented parameter error

  Scenario: Port 1023; low ports allowed
    Given the test server allows low data ports
    And a successful login
    Then the client successfully sends "EPRT |1|2.3.4.3|255|"

  Scenario: Not logged in
    Given a successful connection
    When the client sends "EPRT |1|2.3.4.5|6|"
    Then the server returns a not logged in error

  Scenario: Too few parts
    Given a successful login
    When the client sends "EPRT |1|2.3.4|"
    Then the server returns a syntax error

  Scenario: Too many parts
    Given a successful login
    When the client sends "EPRT |1|2.3.4|5|6|"
    Then the server returns a syntax error

  Scenario: Unknown network protocol
    Given a successful login
    When the client sends "EPRT |3|2.3.4.5|6|"
    Then the server returns a network protocol not supported error

  Scenario: After "EPSV ALL"
    Given a successful login
    Given the client successfully sends "EPSV ALL"
    When the client sends "EPRT |1|2.3.4.5|6|"
    Then the server sends a not allowed after epsv all error
