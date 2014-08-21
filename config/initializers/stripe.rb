Rails.configuration.stripe = {
  	:publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_test_PmuJZVp29uWJQmfVSNgSu9ge",
  	:secret_key      => ENV['SECRET_KEY'] || "sk_test_hxAdGnSvoOIlhgymXdDe3xNs"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]