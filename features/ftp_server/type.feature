Feature: Representation Type

  As a client
  I want to set the representation type
  So that I can interoperate with foreign operating systems

  Background:
    Given the test server is started

  Scenario: ASCII/default
    Given a successful login
    Then the client successfully sets type "A"

  Scenario: ASCII/Non-print
    Given a successful login
    Then the client successfully sets type "A N"

  Scenario: ASCII/Telnet
    Given a successful login
    When the client successfully sets type "A T"

  Scenario: Type IMAGE
    Given a successful login
    Then the client successfully sets type "I"

  Scenario: Type EBCDIC
    Given a successful login
    When the client sets type "E"
    Then the server returns a type not implemented error

  Scenario: Type Local
    Given a successful login
    When the client sets type "L 7"
    Then the server returns a type not implemented error

  Scenario: Invalid Type
    Given a successful login
    When the client sets type "*"
    Then the server returns an invalid type error

  Scenario: Format Carriage Control
    Given a successful login
    When the client sets type "A C"
    Then the server returns a type not implemented error

  Scenario: Invalid Format
    Given a successful login
    When the client sets type "A *"
    Then the server returns an invalid type error

  Scenario: Not logged in
    Given a successful connection
    When the client sets type "S"
    Then the server returns a not logged in error

  Scenario: Missing parameter
    Given a successful login
    When the client sets type with no parameter
    Then the server returns a syntax error
