require "rake"
require "bundler/gem_tasks"


namespace :versions do

  # desc "Run specs on all spec apps"
  # task :spec do
  #   success = true
  #   for_each_directory_of('spec/**/Rakefile') do |directory|
  #     env = "SPEC=../../#{ENV['SPEC']} " if ENV['SPEC']
  #     success &= system("cd #{directory} && #{env} bundle exec rake spec")
  #   end
  #   fail "Tests failed" unless success
  # end

  namespace :bundle do

    desc "Bundle all spec apps"
    task :install do
      for_each_directory_of('cucumber_version/**/Gemfile') do |directory|
        Bundler.with_clean_env do
          system("cd #{directory} && bundle install")
        end
      end
    end

    # desc "Update all gems, or a list of gem given by the GEM environment variable"
    # task :update do
    #   for_each_directory_of('spec/**/Gemfile') do |directory|
    #     Bundler.with_clean_env do
    #       system("cd #{directory} && bundle update #{ENV['GEM']}")
    #     end
    #   end
    # end

  end

  desc "Test all supported cucumber versions"
  task :test do
    for_each_directory_of('cucumber_version/**/Gemfile') do |directory|
      Bundler.with_clean_env do
        clean_outputs(directory)
#        system("cd #{directory} && bundle exec cucumber ../../features/ --format CucumberCharacteristics::Formatter")
        system("cd #{directory} && bundle exec cucumber --color --format progress ../../features/")
        system("bundle exec rspec -r #{directory}/output_path.rb ")
      end
    end
  end

end

def clean_outputs(dir)
  [ "#{dir}/features/characteristics/cucumber_step_characteristics.json",
    "#{dir}/features/characteristics/cucumber_step_characteristics.html"
  ].each do | file |
    File.delete(file) if File.exist?(file)
  end
end

def for_each_directory_of(path, &block)
  Dir[path].sort.each do |rakefile|
    directory = File.dirname(rakefile)
    puts '', "\033[44m#{directory}\033[0m", ''
    block.call(directory)
  end
end
