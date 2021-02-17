module JobseekerHelpers
  def resend_confirmation_email
    visit first_link_from_last_mail
    click_on I18n.t("buttons.resend_email")
  end

  def resend_unlock_instructions_email
    fill_in "Email address", with: jobseeker.email
    within(".new_jobseeker") do
      click_on I18n.t("jobseekers.unlocks.new.form_submit")
    end
  end

  def sign_up_jobseeker(email: jobseeker.email, password: jobseeker.password)
    fill_in "Email address", with: email
    fill_in "Password", with: password
    click_on I18n.t("buttons.continue")
  end

  def sign_in_jobseeker(email: jobseeker.email, password: jobseeker.password)
    fill_in "Email address", with: email
    fill_in "Password", with: password
    within(".new_jobseeker") do
      click_on I18n.t("buttons.sign_in")
    end
  end

  def fill_in_ask_for_support
    choose "Yes", name: "jobseekers_job_application_ask_for_support_form[support_needed]"
    fill_in "Tell us any information you think is relevant", with: "Some details about support"
  end

  def fill_in_current_role
    fill_in "School or other organisation", with: "The Best School"
    fill_in "Job title", with: "The Best Teacher"
    fill_in "Main duties", with: "Some details about what the main duties were"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(1i)]", with: "2019"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(2i)]", with: "09"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(3i)]", with: "01"
    choose "Yes", name: "jobseekers_job_application_details_employment_history_form[current_role]"
  end

  def fill_in_declarations
    choose "Yes", name: "jobseekers_job_application_declarations_form[banned_or_disqualified]"
    choose "Yes", name: "jobseekers_job_application_declarations_form[close_relationships]"
    fill_in "Please give details", with: "Some details of the relationship"
    choose "Yes", name: "jobseekers_job_application_declarations_form[right_to_work_in_uk]"
  end

  def fill_in_employment_history
    fill_in "School or other organisation", with: "The Best School"
    fill_in "Job title", with: "The Best Teacher"
    fill_in "Main duties", with: "Some details about what the main duties were"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(1i)]", with: "2019"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(2i)]", with: "09"
    fill_in "jobseekers_job_application_details_employment_history_form[started_on(3i)]", with: "01"
    choose "No", name: "jobseekers_job_application_details_employment_history_form[current_role]"
    fill_in "jobseekers_job_application_details_employment_history_form[ended_on(1i)]", with: "2020"
    fill_in "jobseekers_job_application_details_employment_history_form[ended_on(2i)]", with: "07"
    fill_in "jobseekers_job_application_details_employment_history_form[ended_on(3i)]", with: "30"
    fill_in "Reason for leaving", with: "Some details about the reason for leaving"
  end

  def fill_in_personal_details
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Frusciante"
    fill_in "Building and street", with: "123 Fake Street"
    fill_in "Town or city", with: "Fakeopolis"
    fill_in "Postcode", with: "F1 4KE"
    fill_in "Phone number", with: "01234 123456"
    fill_in "Teacher reference number", with: "AB 99/12345"
    fill_in "National Insurance number", with: "AB 12 12 12 A"
  end

  def fill_in_personal_statement
    fill_in "Your personal statement", with: "A brilliant, glowing statement about your person"
  end

  def fill_in_professional_status
    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"
    fill_in "Year QTS was awarded", with: Time.current.year
    choose "Yes", name: "jobseekers_job_application_professional_status_form[statutory_induction_complete]"
  end

  def fill_in_reference
    fill_in "Name", with: "Jim Referee"
    fill_in "Job title", with: "Important job"
    fill_in "Organisation", with: "Important organisation"
    fill_in "Relationship to applicant", with: "Colleague"
    fill_in "Email address", with: "test@email.com"
    fill_in "Phone number", with: "09999 123456"
  end
end
