# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'resque'

# Initialize the Rails application.
Buildhawk::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :port           => '25',
  :address        => ENV['POSTMARK_SMTP_SERVER'],
  :user_name      => ENV['POSTMARK_API_KEY'],
  :password       => ENV['POSTMARK_API_KEY'],
  :domain         => 'www.buildhawk.com',
  :authentication => :plain,
}
ActionMailer::Base.delivery_method = :smtp

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      # Re-establish redis connection
      Resque.redis.client.reconnect
    end
  end
end