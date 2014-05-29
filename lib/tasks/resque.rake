require "resque/tasks"

task "resque:setup" => :environment

desc "Alias for apn:work (To run workers on Heroku)"
task "jobs:work" => "apn:work"