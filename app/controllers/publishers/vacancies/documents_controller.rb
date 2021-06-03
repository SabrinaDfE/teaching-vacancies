require "google/apis/drive_v3"

class Publishers::Vacancies::DocumentsController < Publishers::Vacancies::BaseController
  include Publishers::Wizardable

  CONTENT_TYPES_ALLOWED = %w[ application/pdf
                              image/jpeg
                              image/png
                              video/mp4
                              application/msword
                              application/vnd.ms-excel
                              application/vnd.ms-powerpoint
                              application/vnd.openxmlformats-officedocument.wordprocessingml.document
                              application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                              application/vnd.openxmlformats-officedocument.presentationml.presentation ].freeze
  FILE_SIZE_LIMIT = 10.megabytes

  helper_method :form

  before_action :redirect_to_next_step, only: %i[create]

  def create
    process_documents!&.each do |document|
      vacancy.documents.create(document)
    end

    render :show
  end

  def destroy
    document = vacancy.documents.find(params[:id])
    delete_operation_status = DocumentDelete.new(document).delete
    flash_type = delete_operation_status ? :success : :error
    flash_message = t("jobs.file_delete_#{flash_type}_message", filename: document.name)

    if request.xhr?
      flash.now[flash_type] = flash_message
      render :destroy, layout: false, status: delete_operation_status ? :ok : :bad_request
    else
      flash[flash_type] = flash_message
      redirect_to organisation_job_documents_path(vacancy.id)
    end
  end

  private

  def step
    :supporting_documents
  end

  def form
    @form ||= Publishers::JobListing::DocumentsForm.new(documents_form_params, vacancy)
  end

  def documents_form_params
    (params[:publishers_job_listing_documents_form] || params).permit(documents: [])
  end

  def redirect_to_next_step
    if params[:commit] == t("buttons.save_and_return_later")
      redirect_saved_draft_with_message
    elsif params[:commit] == t("buttons.update_job")
      vacancy.update(completed_step: steps_config[step][:number])
      redirect_updated_job_with_message
    elsif params[:commit] == t("buttons.continue")
      vacancy.update(completed_step: steps_config[step][:number])
      redirect_to organisation_job_build_path(vacancy.id, :applying_for_the_job)
    end
  end

  def process_documents!
    documents_form_params[:documents]&.each_with_object([]) do |document_params, documents_array|
      document_upload = upload_document!(document_params)
      document_hash = document_attributes(document_params, document_upload)
      next if errors_on_file?(document_params.original_filename)

      documents_array << document_hash
    end
  end

  def upload_document!(document_params)
    add_pre_upload_file_errors(document_params)

    if errors_on_file?(document_params.original_filename)
      Rails.logger.info("Failed to upload #{document_params.original_filename}: #{form.errors.full_messages.join(', ')}")
      return
    end

    document_upload = DocumentUpload.new(
      upload_path: document_params.tempfile.path,
      name: document_params.original_filename,
    )

    document_upload.upload!

    add_google_error(document_params.original_filename) if document_upload.google_error
    add_virus_error(document_params.original_filename) unless document_upload.safe_download

    return if errors_on_file?(document_params.original_filename)

    vacancy.supporting_documents.attach(document_params)

    document_upload
  end

  def add_pre_upload_file_errors(document_params)
    add_file_type_error(document_params.original_filename) unless valid_content_type?(document_params.tempfile)
    add_file_size_error(document_params.original_filename) if document_params.size > FILE_SIZE_LIMIT
  end

  def add_file_type_error(filename)
    form.errors.add(:documents, t("jobs.file_type_error_message", filename: filename))
  end

  def add_file_size_error(filename)
    form.errors.add(:documents, t("jobs.file_size_error_message", filename: filename, size_limit: helpers.number_to_human_size(FILE_SIZE_LIMIT)))
  end

  def add_google_error(filename)
    form.errors.add(:documents, t("jobs.file_google_error_message", filename: filename))
  end

  def add_virus_error(filename)
    form.errors.add(:documents, t("jobs.file_virus_error_message", filename: filename))
  end

  def errors_on_file?(filename)
    form.errors.messages.values.join(" ").include?(filename)
  end

  def document_attributes(params, upload)
    {
      name: params.original_filename,
      size: Integer(params.size),
      content_type: params.content_type,
      download_url: upload.uploaded.web_content_link,
      google_drive_id: upload.uploaded.id,
    }
  end

  def valid_content_type?(file)
    content_type = MimeMagic.by_magic(file)&.type
    return true if CONTENT_TYPES_ALLOWED.include?(content_type)

    Rails.logger.error("Attempted to upload forbidden file type '#{content_type}'")
    false
  end
end
