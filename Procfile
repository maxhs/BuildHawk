web: bundle exec passenger start -p $PORT
resque_worker:  QUEUE=* rake environment resque:work
worker:  		bundle exec rake jobs:work
apn_worker:     bundle exec rake apn:work