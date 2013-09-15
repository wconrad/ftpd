Feature: EPSV

  As a programmer
  I want good error messages
  So that I can correct problems

  Background:
    Given the test server is bound to "::"
    And the test server is started

  Scenario: No argument
    Given a successful login
    Then the client successfully sends "EPSV"

  Scenario: Explicit IPV4
    Given a successful login
    Then the client successfully sends "EPSV 1"

  Scenario: Explicit IPV6
    Given a successful login
    Then the client successfully sends "EPSV 2"

  Scenario: After "EPSV ALL"
    Given a successful login
    Given the client successfully sends "EPSV ALL"
    Then the client successfully sends "EPSV"

  Scenario: Not logged in
    Given a successful connection
    When the client sends "EPSV"
    Then the server returns a not logged in error

  Scenario: Unknown network protocol
    Given a successful login
    When the client sends "EPSV 99"
    Then the server returns a network protocol not supported error
