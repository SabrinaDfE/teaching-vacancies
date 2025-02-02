# This becomes the superclass of all Devise controllers
class AuthenticationController < ApplicationController
  private

  def sign_out_jobseeker!
    sign_out(:jobseeker)
  end

  def sign_out_publisher!
    clear_extra_publisher_session_entries

    sign_out(:publisher)
  end

  def clear_extra_publisher_session_entries
    session.delete(:publisher_id)
    session.delete(:publisher_organisation_id)
    session.delete(:visited_new_features_page)
    session.delete(:visited_application_feature_reminder_page)

    session[:publisher_dsi_token_hint] = session.delete(:publisher_dsi_token)
  end

  def trigger_jobseeker_sign_in_event(success_or_failure, errors = nil)
    request_event.trigger(
      :jobseeker_sign_in_attempt,
      email_identifier: StringAnonymiser.new(params.dig(:jobseeker, :email)),
      success: success_or_failure == :success,
      errors: errors,
    )
  end

  def trigger_publisher_sign_in_event(success_or_failure, sign_in_type, publisher_oid = nil)
    request_event.trigger(
      :publisher_sign_in_attempt,
      user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid),
      success: success_or_failure == :success,
      sign_in_type: sign_in_type,
    )
  end
end
