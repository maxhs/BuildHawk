web: bundle exec rails server -p $PORT
web: rackup -p $PORT
resque_worker:  QUEUE=* rake environment resque:work
worker:  		bundle exec rake jobs:work
apn_worker:     bundle exec rake jobs:work
sidekiq_worker: bundle exec sidekiq