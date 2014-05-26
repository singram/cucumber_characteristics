Feature: As a user I want to understand where my tests are spending their time in a scenaio with a pending step

  Scenario: Timings for normal scenario
    Given I wait 1 seconds
    When I call a pending step
    Then I wait 1 seconds
