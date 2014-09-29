web: 			bundle exec passenger start -p $PORT --max-pool-size 3
scheduler:  	bundle exec rake resque:scheduler
jobs_worker:    bundle exec rake jobs:work
resque_worker: 	QUEUE=* rake environment resque:work