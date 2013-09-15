Feature: PASV

  As a programmer
  I want good error messages
  So that I can correct problems

  Background:
    Given the test server is started

  Scenario: No argument
    Given a successful login
    Then the client successfully sends "PASV"

  Scenario: After "EPSV ALL"
    Given a successful login
    Given the client successfully sends "EPSV ALL"
    When the client sends "PASV"
    Then the server sends a not allowed after epsv all error

  Scenario: Not logged in
    Given a successful connection
    When the client sends "EPSV"
    Then the server returns a not logged in error
