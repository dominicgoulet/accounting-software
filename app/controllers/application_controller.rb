# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def current_user
    return nil unless signed_in?

    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def current_organization
    return nil unless signed_in?

    @current_organization ||= current_user.current_organization
  end
  helper_method :current_organization

  def ninetyfour_integration
    current_organization.integrations.find_by(system: true, internal_code: 'NINETYFOUR')
  end

  def signed_in?
    session[:user_id].present?
  end
  helper_method :signed_in?

  def sign_in!(user)
    session[:user_id] = user.id
    redirect_to root_path
  end
  helper_method :sign_in!

  def sign_out!
    session[:user_id] = nil
    redirect_to root_path
  end
  helper_method :sign_out!

  def current_action?(name)
    name.include? params[:action]
  end
  helper_method :current_action?

  def current_controller?(name)
    params[:controller].split('/').include? name
  end
  helper_method :current_controller?

  def sti_path(action = nil)
    args = [params[:type].underscore.downcase.pluralize.to_sym]

    if action.present?
      args = if [:new].include? action
               [action, params[:type].underscore.downcase.to_sym]
             else
               [action, params[:type].underscore.downcase.pluralize.to_sym]
             end
    end

    polymorphic_path(args)
  end
  helper_method :sti_path

  def sti_name
    params[:type].constantize.model_name.human
  end
  helper_method :sti_name

  private

  def recurring_event_params
    params[:recurring_event].permit(
      :id,
      :frequency,
      :interval,
      :end_repeat,
      :repeat_until,
      :repeat_count,
      day_of_month: [],
      day_of_week: [],
      day_of_year: [],
      month_of_year: []
    )
  end

  def ensure_frame_response
    return unless Rails.env.development?

    redirect_to root_path unless turbo_frame_request?
  end

  def authenticate_user!
    if signed_in?
      if Rails.env.development? && current_user.nil?
        sign_out!
      else
        redirect_to setup_path unless setup_path? || current_organization.setup_completed?
      end
    else
      redirect_to sign_in_path unless public_path?
    end
  end

  def setup_path?
    current_route = Rails.application.routes.recognize_path(request.url, method: request.env['REQUEST_METHOD'])
    current_route[:controller].to_sym == :setup
  rescue ActionController::RoutingError
    false
  end

  def public_path?
    url_to_test = "https://app.ninetyfour.io#{request.path}"
    current_route = Rails.application.routes.recognize_path(url_to_test, method: request.env['REQUEST_METHOD'])

    public_routes = {
      sessions: %i[new create],
      registrations: %i[new create],
      passwords: %i[new create edit update]
    }

    (public_routes[current_route[:controller].to_sym] || []).include? current_route[:action].to_sym
  rescue ActionController::RoutingError
    [
      '/sign_out'
    ].include? request.path
  end

  def handle_not_found
    redirect_to root_path
  end
end
