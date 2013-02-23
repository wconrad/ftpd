Feature: Port

  As a client
  I want to identify the server
  So that I know how it will behave

  Background:
    Given the test server is started

  Scenario: Success
    Given a successful connection
    When the client successfully queries system ID
    Then the server returns a system ID reply

  Scenario: With argument
    Given a successful login
    When the client sends "SYST 1"
    Then the server returns a syntax error
