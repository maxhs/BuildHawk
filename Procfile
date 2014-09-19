web: 			bundle exec unicorn -p $PORT -c ./config/unicorn.rb
scheduler:  	bundle exec rake resque:scheduler
jobs_worker:    bundle exec rake jobs:work
worker: 		bundle exec resque-pool
resque_worker: 	QUEUE=* rake environment resque:work