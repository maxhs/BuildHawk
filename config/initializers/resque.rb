require 'resque'
require 'resque/scheduler'
require 'resque/scheduler/server'

uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis.namespace = "resque:buildhawk-rails"

# If you want to be able to dynamically change the schedule,
# uncomment this line.  A dynamic schedule can be updated via the
# Resque::Scheduler.set_schedule (and remove_schedule) methods.
# When dynamic is set to true, the scheduler process looks for
# schedule changes and applies them on the fly.
# Note: This feature is only available in >=2.0.0.
#Resque::Scheduler.dynamic = true

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

#Resque.schedule = YAML.load_file('config/resque_schedule.yml')

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      Resque.redis.client.reconnect
    end
  end
end