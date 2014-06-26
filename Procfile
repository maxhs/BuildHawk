web: bundle exec passenger start -p $PORT
scheduler:  bundle exec rake resque:scheduler
apn_worker:     bundle exec rake jobs:work