require 'spec_helper'
require 'nokogiri'

describe "HTML Output" do

  before :all do
    @html_output = read_html_output
  end

  it "should have a title" do
    expect(@html_output.css('title').text).to eq "Cucumber Step Characteristics"
  end

  context "step output" do

    let(:steps) { @html_output.css('table#profile_table tr.step_result') }

    it "has 3 defined" do
      expect(steps.size).to eq 3
    end

    context "pending" do

      let(:step) { steps.select{ |tr| tr.css('.step')[0].text =~ /pending/ }.first }

      it "called 1 time" do
        expect(step.css('.total_count').text.strip).to eq '1'
      end

      it "undefined 1 time" do
        expect(step.css('.undef_count').text.strip).to eq '1'
      end

    end

    context "wait" do

      let(:step) { steps.select{ |tr| tr.css('.step')[0].text =~ /wait/ }.first }

      it "called 33 times" do
        expect(step.css('.total_count').text.strip).to eq '33'
      end

      it "passed 31 times" do
        expect(step.css('.passed_count').text.strip).to eq '31'
      end

      it "skipped 2 times" do
        expect(step.css('.skipped_count').text.strip).to eq '2'
      end

      context "timing" do

        it "fastest ~0.1s" do
          expect(step.css('.fastest_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(0.1)
        end

        it "slowest ~1s" do
          expect(step.css('.slowest_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.0)
        end

        it "total ~11.9s" do
          expect(step.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE*3).of(11.9)
        end

      end

    end

    context "fail" do

      let(:step) { steps.select{ |tr| tr.css('.step')[0].text =~ /fail/ }.first }

      it "called 1 time" do
        expect(step.css('.total_count').text.strip).to eq '1'
      end

      it "failed 1 time" do
        expect(step.css('.failed_count').text.strip).to eq '1'
      end

    end

  end

  context "feature output" do

    let(:features) { @html_output.css('table#feature_table tr.feature_result') }

    it "has 8 defined" do
      expect(features.size).to eq 8
    end

    context "failed" do

      let(:failed_features) { features.select{ |tr| tr.css('.status')[0].text =~ /failed/ } }

      it "has 2 features" do
        expect(failed_features.size).to eq 2
      end

      context "failure.feature" do

        let(:feature) { failed_features.select { |tr| tr.css('.feature')[0].text =~ /failure.feature/}.first }

        it "has 3 steps" do
          expect(feature.css('.step_count').text).to eq '3'
        end

        it "takes ~1s" do
          expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.0)
        end

      end

      context "ambiguous.feature" do

        let(:feature) { failed_features.select { |tr| tr.css('.feature')[0].text =~ /ambiguous.feature/}.first }

        it "has 1 step" do
          expect(feature.css('.step_count').text).to eq '1'
        end

        it "takes ~1s" do
          expect(feature.css('.total_time').text).to eq '-'
        end

      end

    end

    context "pending" do

      let(:pending_features) { features.select{ |tr| tr.css('.status')[0].text =~ /undefined/ } }

      it "has 1 features" do
        expect(pending_features.size).to eq 1
      end

      context "pending.feature" do

        let(:feature) { pending_features.select { |tr| tr.css('.feature')[0].text =~ /pending.feature/}.first }

        it "has 3 steps" do
          expect(feature.css('.step_count').text).to eq '3'
        end

        it "takes ~1s" do
          expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.0)
        end

      end

    end

    context "passed" do

      let(:passed_features) { features.select{ |tr| tr.css('.status')[0].text =~ /passed/ } }

      it "has 5 features" do
        expect(passed_features.size).to eq 5
      end

      context "without examples" do

        context "scenario.feature" do

          let(:feature) { passed_features.select { |tr| tr.css('.feature')[0].text =~ /scenario.feature/}.first }

          it "has 3 steps" do
            expect(feature.css('.step_count').text).to eq '3'
          end

          it "takes ~1.5s" do
            expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.5)
          end

        end

        context "scenario_with_background.feature:6" do

          let(:feature) { passed_features.select { |tr| tr.css('.feature')[0].text =~ /scenario_with_background.feature:6/}.first }

          it "has 4 steps" do
            expect(feature.css('.step_count').text).to eq '4'
          end

          it "takes ~1.0s" do
            expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.0)
          end

        end

        context "scenario_with_background.feature:11" do

          let(:feature) { passed_features.select{ |tr| tr.css('.feature')[0].text =~ /scenario_with_background.feature:11/}.first }

          it "has 4 steps" do
            expect(feature.css('.step_count').text).to eq '4'
          end

          it "takes ~2.2s" do
            expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(2.2)
          end

        end

      end

      context "with examples" do

        context "scenario_outline_with_background.feature" do

          let(:feature) { passed_features.select{ |tr| tr.css('.feature')[0].text =~ /scenario_outline_with_background.feature/}.first }

          it "has 10 steps" do
            expect(feature.css('.step_count').text).to eq '10'
          end

          it "takes ~3.6s" do
            expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(3.6)
          end

          context "examples" do

            let(:examples) { @html_output.css('table#scenario_outline_with_background_feature_6') }

            {'| 0.5 | 0.6 | 0.7 |'=>{total_time: 2.4, step_count: '5',
                                     status: 'passed'},
             '| 0.1 | 0.2 | 0.3 |'=>{total_time: 1.2, step_count: '5',
                                     status: 'passed'}}.each do |id, details|

              context "example #{id}" do
                let(:example) { examples.css(".example_result").select{ |tr| tr.css('.example')[0].text == id}.first }

                it "has #{details[:step_count]} steps" do
                  expect(example.css('.step_count').text).to eq details[:step_count]
                end

                it "takes #{details[:total_time]}s" do
                  expect(example.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(details[:total_time])
                end

              end

            end

            context "totals" do

              let(:feature_totals) { examples.css('.example_totals').first }

              it "has 10 steps" do
                expect(feature_totals.css('.step_count').text).to eq '10'
              end

              it "takes ~3.6s" do
                expect(feature_totals.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(3.6)
              end

            end

          end

        end

        context "scenario_outline.feature" do

          let(:feature) { passed_features.select{ |tr| tr.css('.feature')[0].text =~ /scenario_outline.feature/}.first }

          it "has 8 steps" do
            expect(feature.css('.step_count').text).to eq '8'
          end

          it "takes ~1.6s" do
            expect(feature.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.6)
          end

          context "examples" do

            let(:examples) { @html_output.css('table#scenario_outline_feature_3') }

            {'| 0.1 | 0.2 | 0.3 |'=>{total_time: 0.8, step_count: '4',
                                     status: 'passed'},
             '| 0.3 | 0.2 | 0.1 |'=>{total_time: 0.8, step_count: '4',
                                     status: 'passed'}}.each do |id, details|

              context "example #{id}" do
                let(:example) { examples.css(".example_result").select{ |tr| tr.css('.example')[0].text == id}.first }

                it "has #{details[:step_count]} steps" do
                  expect(example.css('.step_count').text).to eq details[:step_count]
                end

                it "takes #{details[:total_time]}s" do
                  expect(example.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(details[:total_time])
                end

              end

            end

            context "totals" do

              let(:feature_totals) { examples.css('.example_totals').first }

              it "has 8 steps" do
                expect(feature_totals.css('.step_count').text).to eq '8'
              end

              it "takes ~1.6s" do
                expect(feature_totals.css('.total_time').text.strip.to_f).to be_within(TIMING_TOLERANCE).of(1.6)
              end

            end

          end

        end

      end

    end

  end

end
