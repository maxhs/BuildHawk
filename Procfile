web: bundle exec rails server -p $PORT
scheduler:  bundle exec rake resque:scheduler
resque_worker:  bundle exec rake environment resque:work
apn_worker:     bundle exec rake jobs:work
web: rackup -p $PORT