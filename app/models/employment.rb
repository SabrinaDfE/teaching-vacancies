class Employment < ApplicationRecord
  belongs_to :job_application
  lockbox_encrypts :organisation, :job_title, :main_duties

  enum employment_type: { job: 0, break: 1 }
end
