# CucumberProfiler

Gem to profile cucumber steps and features

## Installation

Add this line to your application's Gemfile:

    gem 'cucumber_profiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cucumber_profiler

## Usage

TODO: Write usage instructions here

## Problem

The formatting hooks on the face of it provide the necessary event points to profile any given feature file.
This is true for a Scenario, but consider the following ScenaioOutline

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

Running

    cucumber --format debug features/outline.feature

A couple of problems become evident

1. There are step definitions walked prior to the examples_array.  These steps are not invoked rendering these hooks points misleading for profiling purposes
2. There are only 3 table_cell element blocks. These can be profiled, but what about the last step that does not have an input from the examples?

This is why when you use the 'progress' formatter you would get 4 'skipped' for the initial step hooks and then only 6 green dots representing steps when there should be 8 as it key's off table cells not steps.

Possible solutions

1. Introduce new hook point for all true step invokations irregardless of context.
2. Adjust table_cell hooks to include 'null' cells when considering steps without definitions.
3. Include profile information in runtime master object to parse out at end.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
