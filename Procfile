web: bundle exec passenger start -p $PORT
scheduler:  bundle exec rake resque:scheduler
resque_worker: bundle exec rake resque:work
worker:     bundle exec rake jobs:work