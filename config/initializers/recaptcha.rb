Recaptcha.configure do |config|
  config.site_key = Rails.application.secrets.recaptcha[:site]
  config.secret_key = Rails.application.secrets.recaptcha[:key]
end