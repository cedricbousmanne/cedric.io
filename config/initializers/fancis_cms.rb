Rails.application.config.tap do |config|
  config.francis_cms.logged_in_method = :logged_in?
  config.francis_cms.login_path       = '/login' # path may be relative or absolute

  config.francis_cms.site_url         = 'https://cedric.io/' # `site_url` must include protocol and trailing slash
  config.francis_cms.site_title       = 'FrancisCMS Demo Site'
  config.francis_cms.site_description = 'This is the default site description for a new FrancisCMS-powered website.'
  config.francis_cms.site_language    = 'fr-BE'

  config.francis_cms.user_name        = 'Cédric Bousmanne'
  config.francis_cms.user_email       = 'cedric@bousmanne.com'
  config.francis_cms.user_avatar      = 'http://www.placecage.com/180/180' # path may be relative or absolute

  config.francis_cms.license_title    = 'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International'
  config.francis_cms.license_url      = 'http://creativecommons.org/licenses/by-nc-sa/4.0/'

  config.before_configuration do |app|
    app.config.francis_cms.github_profile = "https://github.com/cedricbousmanne"
    app.config.francis_cms.google_plus_profile = "https://plus.google.com/104650554376489234150"
    app.config.francis_cms.twitter_profile = "https://twitter.com/akyrho"
    app.config.francis_cms.facebook_profile = "https://www.facebook.com/706606295"
    app.config.francis_cms.micro_blog_profile = "https://micro.blog/AkyRhO"
    app.config.francis_cms.instagram_profile = "https://www.instagram.com/akyrh0"
  end
end