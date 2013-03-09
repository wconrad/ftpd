Feature: Port

  As a programmer
  I want good error messages
  So that I can correct problems

  Background:
    Given the test server is started

  Scenario: Port 1024
    Given a successful login
    Then the client successfully sends "PORT 1,2,3,4,4,0"

  Scenario: Port 1023; low ports disallowed
    Given the test server disallows low data ports
    And a successful login
    When the client sends "PORT 1,2,3,4,3,255"
    Then the server returns an unimplemented parameter error

  Scenario: Port 1023; low ports allowed
    Given the test server allows low data ports
    And a successful login
    Then the client successfully sends "PORT 1,2,3,4,3,255"

  Scenario: Not logged in
    Given a successful connection
    When the client sends PORT "1,2,3,4,5,6"
    Then the server returns a not logged in error

  Scenario: Incorrect number of bytes
    Given a successful login
    When the client sends PORT "1,2,3,4,5"
    Then the server returns a syntax error

  Scenario: Ill formatted byte
    Given a successful login
    When the client sends PORT "1,2,3,4,5,0006"
    Then the server returns a syntax error

  Scenario: Byte out of range
    Given a successful login
    When the client sends PORT "1,2,3,4,5,256"
    Then the server returns a syntax error
