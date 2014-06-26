web: bundle exec passenger start -p $PORT --max-pool-size 2
resque_worker:  QUEUE=* rake environment resque:work
scheduler:  bundle exec rake resque:scheduler
apn_worker:     bundle exec rake jobs:work