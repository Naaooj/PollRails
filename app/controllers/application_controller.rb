class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :is_logged
  
  before_filter :set_locale

  def set_locale
    locale = params[:locale] || 'fr'
    if I18n.available_locales.include?(locale.to_sym)
      locale = locale
    else
      locale = 'fr'
    end
    #render :text => session[:locale]
    I18n.locale = locale
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def is_logged
    if current_user.nil?
      return false
    end
      return true
  end
  
  def authorize
    unless session[:user_id]
      flash[:notice] = t("please_connect")
      redirect_to(:controller => "home", :action => "index")
    end
  end
end
