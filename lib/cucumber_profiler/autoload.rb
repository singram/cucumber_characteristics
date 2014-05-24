AfterConfiguration do |configuration|
  configuration.options[:formats] << ['CucumberProfiler::Formatter', nil]
end
