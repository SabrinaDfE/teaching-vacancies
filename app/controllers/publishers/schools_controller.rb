class Publishers::SchoolsController < Publishers::BaseController
  def index
    @organisation = current_organisation
  end

  def show
    @organisation = current_publisher.organisations.find(params[:id])
  end

  def edit
    @organisation_form = Publishers::OrganisationForm.new(
      description: organisation.description, website: organisation.website,
    )
  end

  def update
    @organisation_form = Publishers::OrganisationForm.new(organisation_params)

    if @organisation_form.valid?
      organisation.update(organisation_params)
      redirect_to redirect_path, success: t(".success_html", organisation: organisation.name)
    else
      render :edit
    end
  end

  private

  def organisation
    @organisation ||= if current_organisation.school? ||
                         (current_organisation.school_group? && current_organisation.id == params[:id])
                        current_organisation
                      else
                        current_organisation.schools.find(params[:id])
                      end
  end

  def redirect_path
    current_organisation.school? ? publishers_school_path(current_organisation) : publishers_schools_path
  end

  def organisation_params
    params.require(:publishers_organisation_form).permit(:description, :website)
  end
end
