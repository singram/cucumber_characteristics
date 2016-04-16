# CucumberCharacteristics

Gem to profile cucumber steps and features.

## Compatibility

+ (J)Ruby - 1.9.3 -> 2.3.0
+ Cucumber - 1.3.5, 2.1.x+

## High level features

Step analysis including
+ Location of step in steps file & regex
+ Step usage location and number of times executed (background/outline etc)
+ Counts for success/failure/pending/etc
+ Total time taken in test run
+ Average, fastest, slowest times per step
+ Variation, variance & standard deviation calculations

Feature analysis including
+ Feature location
+ Time taken to run feature
+ Result of feature test (pass, fail etc)
+ Number of steps run
+ Breakdown of feature by individual example run if a secario outline

Other features.
+ Reporting of ambiguous step calls
+ Reporting of unused step definitions

## Installation

### Step 1

Add this line to your application's Gemfile:

    gem 'cucumber_characteristics'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cucumber_characteristics


### Step 2

Add the following line to your cucumber environment file typically found at `features\support\env.rb`

    require 'cucumber_characteristics/autoload'

## Usage

1. For always-on automatic loading (recommended), add `require 'cucumber_characteristics/autoload'` to `features/support/yourapp_env.rb`.  It is recommended by cucumber that you do not enhance features/support/env.rb so that upgrades are painless (relatively)

2. Add it to your `cucumber.yml` by adding `--format CucumberCharacteristics::Formatter` i.e.

    `std_opts = "-r features/. -r --quiet --format CucumberCharacteristics::Formatter --format progress"`

3. Use it via command line with `--format CucumberCharacteristics::Formatter`.

## Configuration

You can configure the export of step characteristics via the following (defaults are same as example)

    CucumberCharacteristics.configure do |config|
      config.export_json = true
      config.export_html = true
      config.precision = 4
      config.target_filename =  'cucumber_step_characteristics'
      config.relative_path =  'features/characteristics'
    end

This again can be added to your cucumber environment file typically found at `features\support\env.rb`

## Results

Exported characteristic information is listed out at the end of the cucumber run in a message similar to

    Step characteristic report written to /home/singram/projects/gems/cucumber_characteristics/features/characteristics/cucumber_step_characteristics.html
    Step characteristic report written to /home/singram/projects/gems/cucumber_characteristics/features/characteristics/cucumber_step_characteristics.json

depending on the options specified.

The JSON option is provided for convenience in case there is a further use case/analysis required that is not provided by the gem.

An example can be found [here](features/characteristics/cucumber_step_characteristics.json)

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

1. There are step definitions walked prior to the examples_array.  These steps are not actually invoked rendering these hooks points misleading for profiling purposes
2. There are only 3 table_cell element blocks. These can be profiled, but what about the last step that does not have an input from the examples?  There are no hook points to profile this step.

This is why when you use the 'progress' formatter you would get 4 'skipped' for the initial step hooks triggered and then only 6 green dots representing steps when there should be 8 as it key's off table cells not steps.

Possible solutions

1. Introduce new hook point for all true step invokations irregardless of context.
2. Adjust table_cell hooks to include 'null' cells when considering steps without definitions.
3. Include profile information in runtime master object to parse out at end.

As it turns out it was pretty simple to enhance the runtime object to reliably return profile information.

## Developement

1. Install development environment

    `bundle install`

2. Run formatter over default cucumber version

    `bundle exec cucumber`

3. Run tests across all supported cucumber versions

    `bundle exec rake versions:bundle:install`

    `bundle exec rake versions:test`

* NOTE.  When running the cucumber tests failures, pending etc are expected.  All specs should pass *


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request (after running tests!)

## Credits
1. Ryan Boucher [cucumber_timing_presenter](https://github.com/distributedlife/cucumber_timing_presenter) for inspiration.
2. AlienFast [cucumber_statistics](https://github.com/alienfast/cucumber_statistics) for inspriation.
3. [Brandon Hilker](http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/) for gem building tutorials
