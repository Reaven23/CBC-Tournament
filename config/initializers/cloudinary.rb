# Configuration Cloudinary simple
if ENV['CLOUDINARY_URL'].present?
  Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
else
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
    config.secure = true
    config.cdn_subdomain = true
  end
end
