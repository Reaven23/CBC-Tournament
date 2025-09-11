class ApplicationController < ActionController::Base
  # Include helpers for SEO
  include SeoHelper
  include StructuredDataHelper
end
