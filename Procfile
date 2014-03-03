web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb

scheduler:  bundle exec rake resque:scheduler
resque_worker:  QUEUE=* rake environment resque:work
apn_worker:     bundle exec rake jobs:work
