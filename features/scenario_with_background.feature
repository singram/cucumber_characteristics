Feature: As a user I want to understand where my tests are spending their time in a scenaio with a background

Background:
  Given I wait 0.4 seconds

  Scenario: Timings for normal scenario
    Given I wait 0.1 seconds
    When I wait 0.2 seconds
    Then I wait 0.3 seconds

  Scenario: Timings for another normal scenario
    Given I wait 0.5 seconds
    When I wait 0.6 seconds
    Then I wait 0.7 seconds
