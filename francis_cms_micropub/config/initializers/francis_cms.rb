Rails.application.config.tap do |config|
  config.before_configuration do |app|
    app.config.francis_cms.micropub_endpoint = "/micropub"
  end
end