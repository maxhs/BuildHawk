web: 			bundle exec passenger start -p $PORT --max-pool-size 3
scheduler:  	bundle exec rake resque:scheduler
resque_worker: 	QUEUE=* rake environment resque:work