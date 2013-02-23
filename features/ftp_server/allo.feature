Feature: Port

  As a client
  I want to reserve file system space
  So that my put will succeed

  Background:
    Given the test server is started

  Scenario: With count
    Given a successful login
    When the client successfully sends "ALLO 1024"
    Then the server returns a not necessary reply

  Scenario: With count and record size
    Given a successful login
    When the client successfully sends "ALLO 1024 R 128"
    Then the server returns a not necessary reply

  Scenario: Not logged in
    Given a successful connection
    When the client sends "ALLO 1024"
    Then the server returns a not logged in error

  Scenario: Missing argument
    Given a successful login
    When the client sends "ALLO"
    Then the server returns a syntax error

  Scenario: Invalid argument
    Given a successful login
    When the client sends "ALLO XYZ"
    Then the server returns a syntax error
