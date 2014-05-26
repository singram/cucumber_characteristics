Feature: As a user I want to understand where my tests are spending their time

  Scenario Outline: Timings for scenario outline
    Given I wait <given_wait> seconds
    When  I wait <when_wait> seconds
    Then  I wait <then_wait> seconds
    And   I wait 0.2 seconds
    Examples:
    | given_wait | when_wait | then_wait |
    |          1 |         2 |         3 |
    |          5 |         6 |         7 |

  # Scenario: Timings for normal scenario
  #   Given I wait 1 seconds
  #   When I wait 1 seconds
  #   Then I wait 1 seconds
