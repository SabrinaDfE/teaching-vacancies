module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    job_role_details: %i[additional_job_roles],
    schools: %i[organisation_ids],
    job_details: %i[subjects],
    working_patterns: %i[working_patterns],
  }.freeze

  def job_role_params(params)
    params.require(:publishers_job_listing_job_role_form).permit(:main_job_role).merge(completed_steps: completed_steps)
  end

  def job_role_details_params(params)
    params.require(:publishers_job_listing_job_role_details_form).permit(:send_responsible, additional_job_roles: [])
          .merge(completed_steps: completed_steps)
  end

  def job_location_params(params)
    job_location = params[:publishers_job_listing_job_location_form][:job_location]
    readable_job_location = readable_job_location(
      job_location, school_name: current_organisation.name, schools_count: vacancy.organisation_ids.count
    )
    attributes_to_merge = {
      completed_steps: completed_steps,
      readable_job_location: job_location == "central_office" ? readable_job_location : nil,
      organisation_ids: job_location == "central_office" ? current_organisation.id : nil,
    }
    session[:job_location] = job_location
    params.require(:publishers_job_listing_job_location_form).permit(:job_location).merge(attributes_to_merge.compact)
  end

  def schools_params(params)
    job_location = session[:job_location].presence || vacancy.job_location
    organisation_ids = params[:publishers_job_listing_schools_form][:organisation_ids]
    school_name = if organisation_ids.is_a?(String) && organisation_ids.present?
                    School.find(params[:publishers_job_listing_schools_form][:organisation_ids]).name
                  end
    schools_count = if organisation_ids.is_a?(Array)
                      params[:publishers_job_listing_schools_form][:organisation_ids].count
                    end
    readable_job_location = readable_job_location(job_location, school_name: school_name, schools_count: schools_count)
    attributes_to_merge = {
      completed_steps: completed_steps,
      job_location: job_location,
      readable_job_location: readable_job_location,
    }
    params.require(:publishers_job_listing_schools_form).permit(:organisation_ids, organisation_ids: [])
          .merge(attributes_to_merge.compact)
  end

  def education_phases_params(params)
    # Forms containing only radio buttons do not send the form key param when they're submitted and no radio is selected
    if params["publishers_job_listing_education_phases_form"]
      params.require(:publishers_job_listing_education_phases_form).permit(:phase).merge(completed_steps: completed_steps)
    else
      {}
    end
  end

  def job_details_params(params)
    job_location = vacancy.job_location.presence || "at_one_school"
    readable_job_location = vacancy.readable_job_location.presence || readable_job_location(job_location, school_name: current_organisation.name)
    attributes_to_merge = {
      completed_steps: completed_steps,
      job_location: job_location,
      readable_job_location: readable_job_location,
      organisation_ids: vacancy.organisation_ids.blank? ? current_organisation.id : nil,
      status: vacancy.status.blank? ? "draft" : nil,
    }
    params.require(:publishers_job_listing_job_details_form)
          .permit(:job_title, :contract_type, :contract_type_duration, key_stages: [], subjects: [])
          .merge(attributes_to_merge.compact)
  end

  def working_patterns_params(params)
    params.require(:publishers_job_listing_working_patterns_form).permit(:working_patterns_details, working_patterns: [])
          .merge(completed_steps: completed_steps)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form).permit(:actual_salary, :salary, :benefits)
          .merge(completed_steps: completed_steps)
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:starts_asap, :starts_on, :publish_on, :publish_on_day, :expires_at, :expiry_time)
          .merge(completed_steps: completed_steps)
  end

  def applying_for_the_job_params(params)
    params.require(:publishers_job_listing_applying_for_the_job_form)
          .permit(:application_link, :enable_job_applications, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def job_summary_params(params)
    params.require(:publishers_job_listing_job_summary_form).permit(:job_advert, :about_school)
          .merge(completed_steps: completed_steps)
  end

  private

  def completed_steps
    current_step = defined?(step) ? step.to_s : "review"
    (vacancy.completed_steps | [current_step]).compact
  end
end
