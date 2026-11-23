# Sign-in for setters, from Rails' authentication generator. Changed from the generated version to expire
# sessions, reset the browser session at sign-in and sign-out, and return only to pages that can be visited.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.active.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      # The redirect after sign-in is a GET, so a form's URL might not exist to return to.
      session[:return_to_after_authenticating] = request.url if request.get? || request.head?
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      reset_browser_session_keeping_return_url

      Current.session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      cookies.signed[:session_id] = {
        value: Current.session.id, expires: Session::LIFETIME, httponly: true, same_site: :lax
      }
    end

    def terminate_session
      Current.session.destroy
      Current.session = nil
      cookies.delete(:session_id)
      reset_session
    end

    # A fresh session and CSRF token, so nothing set before sign-in carries over to the signed-in setter.
    def reset_browser_session_keeping_return_url
      return_url = session[:return_to_after_authenticating]
      reset_session
      session[:return_to_after_authenticating] = return_url if return_url
    end
end
