require "rake"
require "bundler/gem_tasks"

# Approach to version testing credited to
#   https://github.com/makandra/cucumber_factory

namespace :versions do

  namespace :bundle do

    desc "Bundle all spec apps"
    task :install do
      for_each_directory_of('cucumber_version/**/Gemfile') do |directory|
        Bundler.with_clean_env do
          system("cd #{directory} && bundle install")
        end
      end
    end

  end

  desc "Test all supported cucumber versions"
  task :test do
    for_each_directory_of('cucumber_version/**/Gemfile') do |directory|
      Bundler.with_clean_env do
        clean_outputs(directory)
        system("cd #{directory} && bundle exec cucumber --color --format progress -g -r ../../features/ ../../features/")
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
