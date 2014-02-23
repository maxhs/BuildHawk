Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_test_23emORqBWZz8YhjkR2vsXjSm",
  :secret_key      => ENV['SECRET_KEY'] || "sk_test_BUXFDUpWt1ZFZ3s6NBzqBOFG"
  ## LIVE
  #:publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_live_weQFPFprD1yqXFhy8RiqdRn0",
  #:secret_key      => ENV['SECRET_KEY'] || "sk_live_873aFSibbbwVdttkIVScEhNc"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]