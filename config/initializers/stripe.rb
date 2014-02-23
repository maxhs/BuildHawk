Rails.configuration.stripe = {
  #:publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_test_23emORqBWZz8YhjkR2vsXjSm",
  #:secret_key      => ENV['SECRET_KEY'] || "sk_test_BUXFDUpWt1ZFZ3s6NBzqBOFG"
  :publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_test_8JBQJLxliyXgo5GCgT85PvMf",
  :secret_key      => ENV['SECRET_KEY'] || "sk_test_Bp7u2F08RTln53YMKDYqm3mW"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]