require "resque/tasks"
require 'resque_scheduler/tasks'

#task "resque:setup" => :environment
task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end
task "apn:setup" => :environment do
  ENV['QUEUE'] = '*'
end

desc "Alias for apn:work (To run workers on Heroku)"
task "jobs:work" => "apn:work"