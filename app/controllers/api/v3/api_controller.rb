class Api::V3::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
end