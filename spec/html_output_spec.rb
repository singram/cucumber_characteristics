require 'spec_helper'
require 'nokogiri'

describe "HTML Output" do

  step_expectations = {'pending step'    => {total_count: 1, undef_count: 1},
                       'wait_steps'      => {total_count: 33, passed_count: 31,
                                             skipped_count: 2,
                                             timings: {fastest_time: 0.1,
                                                       slowest_time: 1.0 , total_time: 11.9 }},
                       'fail_steps'      => {total_count: 1, failed_count: 1},
                       'ambiguous_steps' => {total_count: 1, passed_count: 1}}

  feature_expectations = {
    'failure.feature' => {step_count: 3, total_time: 1.0, status: 'failed'},
    'pending.feature' => {step_count: 3, total_time: 1.0,
                          status: 'undefined'},
    'scenario_outline_with_background.feature:6' => {step_count: 10, total_time: 3.6,
                                                     status: 'passed',
                                                     examples: {'| 0.5 | 0.6 | 0.7 |'=>{total_time: 2.4, step_count: 5,
                                                                                        status: 'passed'},
                                                                '| 0.1 | 0.2 | 0.3 |'=>{total_time: 1.2, step_count: 5,
                                                                                        status: 'passed'}}},
    'scenario_with_background.feature:11' => {step_count: 4, total_time: 2.2,
                                              status: 'passed'},
    'scenario_with_background.feature:6' => {step_count: 4, total_time: 1.0,
                                             status: 'passed'},
    'scenario_outline.feature:3' => {step_count: 8, total_time: 1.6,
                                     status: 'passed',
                                     examples: {'| 0.1 | 0.2 | 0.3 |'=>{total_time: 0.8, step_count: 4,
                                                                        status: 'passed'},
                                                '| 0.3 | 0.2 | 0.1 |'=>{total_time: 0.8, step_count: 4,
                                                                        status: 'passed'}}},
    'scenario.feature' => {step_count: 3, total_time: 1.5,
                           status: 'passed'},
    'ambiguous.feature' => {step_count: 1, total_time: 0.0,
                            status: 'passed'}}



  before :all do
    @html_output = read_html_output
  end

  it "should have a title" do
    expect(@html_output.css('title').text).to eq "Cucumber Step Characteristics"
  end

  context "step output" do

    let(:steps) { @html_output.css('table#profile_table tr.step_result') }

    it "has #{step_expectations.size} defined" do
      expect(steps.size).to eq step_expectations.size
    end

    step_expectations.each do |step_match, expectations|

      context "#{step_match}" do

        let(:step) { steps.select{ |tr| tr.css('.step')[0].text =~ /#{step_match}/ }.first }

        timings = expectations.delete(:timings)
        expectations.each do |type, expectation|
          it "#{type} of #{expectation}" do
            expect(step.css(".#{type}").text.strip).to eq expectation.to_s
          end
        end

        if timings
          context "timing" do
            timings.each do |type, expectation|
              it "#{type} ~#{expectation}s" do
                expect(step.css(".#{type}").text.strip.to_f).to be_within(TIMING_TOLERANCE).of(expectation)
              end
            end
          end
        end

      end

    end

  end

  context "feature output" do

    let(:features) { @html_output.css('table#feature_table tr.feature_result') }

    it "has #{feature_expectations.size} defined" do
      expect(features.size).to eq feature_expectations.size
    end

    feature_expectations.each do | feature_name, expectations |
      context feature_name do

        let(:feature) { features.select { |tr| tr.css('.feature')[0].text =~ /#{feature_name}/}.first }

        it "has #{expectations[:step_count]} steps" do
          expect(feature.css('.step_count').text).to eq expectations[:step_count].to_s
        end

        it "has #{expectations[:status]} result" do
          expect(feature.css('.status').text).to eq expectations[:status].to_s
        end

        it "takes ~#{expectations[:total_time]}s" do
          expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(expectations[:total_time])
        end

        if expectations[:examples]

          context "examples" do

            let(:examples) { @html_output.css("table##{feature_name.gsub(/[\.:]/, '_')}") }

            expectations[:examples].each do |id, details|

              context "example #{id}" do
                let(:example) { examples.css(".example_result").select{ |tr| tr.css('.example')[0].text == id}.first }

                it "has #{details[:step_count]} steps" do
                  expect(example.css('.step_count').text).to eq details[:step_count].to_s
                end

                it "takes #{details[:total_time]}s" do
                  expect(example.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(details[:total_time])
                end

                it "has #{details[:status]} result" do
                  expect(example.css('.status').text).to eq details[:status].to_s
                end

              end

            end

            context "totals" do

              let(:feature_totals) { examples.css('.example_totals').
                                     first }

              total_steps = expectations[:examples].map{ |k,v| v[:step_count] }.inject(&:+)
              total_time = expectations[:examples].map{ |k,v| v[:total_time] }.inject(&:+)

              it "has #{total_steps} steps" do
                expect(feature_totals.css('.step_count').text).to eq total_steps.to_s
              end

              it "takes ~#{total_time}s" do
                expect(feature_totals.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(total_time)
              end

            end

          end

        end

      end

    end

  end

end
