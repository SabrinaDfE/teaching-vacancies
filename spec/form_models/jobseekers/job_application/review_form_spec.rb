require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ReviewForm, type: :model do
  let(:completed_steps) { [] }

  subject do
    described_class.new({ confirm_data_accurate: "1", confirm_data_usage: "1", completed_steps: completed_steps })
  end

  it { is_expected.to validate_acceptance_of(:confirm_data_accurate) }
  it { is_expected.to validate_acceptance_of(:confirm_data_usage) }

  context "when all steps are complete" do
    let(:completed_steps) { JobApplication.completed_steps.keys }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when there are incomplete steps" do
    let(:completed_steps) { %w[personal_details professional_status employment_history references ask_for_support] }
    let(:incomplete_steps) { %i[personal_statement equal_opportunities declarations] }

    it "is invalid" do
      expect(subject).not_to be_valid
      incomplete_steps.each do |incomplete_step|
        expect(subject.errors.messages_for(incomplete_step))
          .to include(I18n.t("activemodel.errors.models.jobseekers/job_application/review_form.attributes.#{incomplete_step}.incomplete"))
      end
    end
  end
end
