web: bundle exec passenger start -p $PORT
scheduler:  bundle exec rake resque:scheduler
worker: bundle exec rake jobs:work