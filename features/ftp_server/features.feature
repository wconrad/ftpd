Feature: Features

  As a client
  I want to know what FTP extension the server supports
  So that I can use them without trial-and-error

  Background:

  Scenario: TLS Disabled
    Given the test server is started
    And the client connects
    When the client successfully requests features
    Then the response should not include TLS features

  Scenario: TLS Enabled
    Given the test server has TLS mode "explicit"
    And the test server is started
    And the client connects
    When the client successfully requests features
    Then the response should include TLS features

  Scenario: Argument given
    Given the test server is started
    And the client connects
    When the client sends "FEAT FOO"
    Then the server returns a syntax error

  Scenario: IPV6 Extensions
    Given the test server is started
    And the client connects
    When the client successfully requests features
    Then the response should include feature "EPRT"
    And the response should include feature "EPSV"

  Scenario: RFC 3659 Extensions
    Given the test server is started
    And the client connects
    When the client successfully requests features
    Then the response should include feature "SIZE"
    Then the response should include feature "MDTM"
