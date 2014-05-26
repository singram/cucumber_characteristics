Given(/^I wait ([\d\.]+) seconds$/) do |s|
  sleep(s.to_f)
end
