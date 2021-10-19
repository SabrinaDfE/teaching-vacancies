class Publishers::NewFeaturesController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update reminder]

  def show
    @new_features_form = Publishers::NewFeaturesForm.new
    current_publisher.update(viewed_new_features_page_at: Time.current)
  end

  def update
    @new_features_form = Publishers::NewFeaturesForm.new(new_features_params)

    current_publisher.update(dismissed_new_features_page_at: Time.current) if new_features_params[:dismiss].present?
    session[:visited_new_features_page] = true
    redirect_to organisation_path
  end

  def reminder
    current_publisher.update(viewed_application_feature_reminder_page_at: Time.current)
  end

  private

  def new_features_params
    (params[:publishers_new_features_form] || params).permit(:dismiss)
  end
end
