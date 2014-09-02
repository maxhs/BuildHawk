Rails.configuration.stripe = {
  	:publishable_key => ENV['PUBLISHABLE_KEY'] || 'pk_test_7kFA8dVVszsUyc5XCfhcwGxV',
  	:secret_key      => ENV['SECRET_KEY'] || 'sk_test_mrKlCJDHjJu0MLTTVh8tz62w'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]