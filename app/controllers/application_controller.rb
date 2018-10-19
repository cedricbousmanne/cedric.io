class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def logged_in?
    # Your application-specific authentication logic would go here.
    # This method should return a boolean `true` or `false`.
    true
  end
  helper_method :logged_in?
end
