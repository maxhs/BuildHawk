web: bundle exec passenger start -p $PORT
resque_worker:  QUEUE=* rake environment resque:work
scheduler:  bundle exec rake resque:scheduler
apn_worker:     bundle exec rake jobs:work