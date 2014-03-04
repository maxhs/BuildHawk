worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

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

  if defined?(Resque)
    uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
    #Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    Resque.redis = ENV['<REDIS_URI>']
    Rails.logger.info('Connected to Redis')
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end