web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
scheduler:  bundle exec rake resque:scheduler
resque_worker:  bundle exec rake environment resque:work
apn_worker:     bundle exec rake jobs:work
web: rackup -p $PORT