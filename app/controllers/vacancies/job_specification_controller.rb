class Vacancies::JobSpecificationController < Vacancies::ApplicationController
  def new
    @job_specification_form = JobSpecificationForm.new(school_id: school.id)
    return unless session[:current_step].eql?('step_1')

    @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
    @job_specification_form.valid?
  end

  def create
    @job_specification_form = JobSpecificationForm.new(job_specification_form)
    store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)

    if @job_specification_form.valid?
      session_vacancy_id ? update_vacancy(job_specification_form) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes.compact!)

      redirect_to step_2_school_vacancies_path(school_id: school.id)
    else
      session[:current_step] = :step_1
      redirect_to job_specification_school_vacancy_path(school_id: school.id)
    end
  end

  private

  def job_specification_form
    params.require(:job_specification_form).permit(:job_title, :job_description, :headline,
                                                   :minimum_salary, :maximum_salary, :working_pattern,
                                                   :school_id, :subject_id, :pay_scale_id, :leadership_id,
                                                   :starts_on_dd, :starts_on_mm, :starts_on_yyyy,
                                                   :ends_on_dd, :ends_on_mm, :ends_on_yyyy)
  end
end
