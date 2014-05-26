Feature: As a user I want to understand where my tests are spending their time in a scenaio with a pending step

  Scenario: Timings for normal scenario
    Given I wait 1 seconds
    When I fail
    Then I wait 1 seconds
