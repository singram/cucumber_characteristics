require 'spec_helper'
require 'nokogiri'

unless defined?(CHARACTERISTICS_OUTPUT_PATH_PREFIX)
  CHARACTERISTICS_OUTPUT_PATH_PREFIX = ""
end

require 'pp'

def read_html_output
  begin
    output_file = "#{CHARACTERISTICS_OUTPUT_PATH_PREFIX}features/characteristics/cucumber_step_characteristics.html"
    puts "Testing - #{output_file}"
    File.open(output_file) { |f| Nokogiri::HTML(f) }
  rescue Errno::ENOENT => e
    puts "Could not find file '#{output_file}'"
    exit
  end
end

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
      expect(@html_output.css('table#profile_table tr.step_result').size).to eq 3
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
          expect(step.css('.fastest_time').text.strip.to_f).to be_within(0.05).of(0.1)
        end

        it "slowest ~1s" do
          expect(step.css('.slowest_time').text.strip.to_f).to be_within(0.05).of(1.0)
        end

        it "total ~12s" do
          expect(step.css('.total_time').text.strip.to_f).to be_within(0.05).of(12.0)
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

  describe "feature output" do

    it "should have "

  end


end
