# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = (ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
    Rails.logger.info('Connected to Redis')
  end
  
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end