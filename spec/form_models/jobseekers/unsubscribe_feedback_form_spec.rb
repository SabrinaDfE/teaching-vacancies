require "rails_helper"

RSpec.describe Jobseekers::UnsubscribeFeedbackForm, type: :model do
  it { is_expected.to validate_inclusion_of(:unsubscribe_reason).in_array(Feedback.unsubscribe_reasons.keys) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it { is_expected.to validate_inclusion_of(:user_participation_response).in_array(Feedback.user_participation_responses.keys) }

  context "when reason is job_found" do
    before { allow(subject).to receive(:unsubscribe_reason).and_return("job_found") }

    it { is_expected.not_to validate_presence_of(:other_unsubscribe_reason_comment) }
  end

  context "when reason is other_reason" do
    before { allow(subject).to receive(:unsubscribe_reason).and_return("other_reason") }

    it { is_expected.to validate_presence_of(:other_unsubscribe_reason_comment) }
  end

  describe "#email" do
    context "when the jobseeker has chosen to participate in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("interested") }
      it { is_expected.to validate_presence_of(:email) }
    end

    context "when the jobseeker has chosen to not participate in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("uninterested") }
      it { is_expected.not_to validate_presence_of(:email) }
    end
  end
end
