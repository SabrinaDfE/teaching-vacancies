require "rails_helper"

RSpec.describe Jobseekers::SubscriptionForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    before { stub_const("Search::LocationBuilder::DEFAULT_RADIUS", "32") }

    context "when a radius is provided" do
      context "when a location is provided" do
        let(:params) { { radius: "1", location: "North Nowhere" } }

        it "assigns the radius attribute to the radius param" do
          expect(subject.radius).to eq("1")
        end
      end

      context "when a location is not provided" do
        let(:params) { { radius: "1" } }

        it "assigns the radius to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end
    end

    context "when a radius is not provided" do
      context "when a location is provided" do
        let(:params) { { location: "North Nowhere" } }

        it "assigns the radius attribute to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end

      context "when a location is not provided" do
        let(:params) { {} }

        it "assigns the radius to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end
    end

    context "when a radius is provided in the search criteria param" do
      context "when a location is provided" do
        let(:params) { { search_criteria: { radius: "1" }, location: "North Nowhere" } }

        it "assigns the radius attribute to the radius param" do
          expect(subject.radius).to eq("1")
        end
      end

      context "when a location is not provided" do
        let(:params) { { search_criteria: { radius: "1" } } }

        it "assigns the radius to the default radius" do
          expect(subject.radius).to eq("32")
        end
      end
    end
  end

  describe "#search_criteria_hash" do
    let(:params) { { keyword: keyword, job_roles: job_roles, radius: radius, location: location } }
    let(:keyword) { "physics" }
    let(:radius) { nil }
    let(:location) { nil }
    let(:job_roles) { [] }

    context "when a value is blank" do
      let(:keyword) { "" }
      let(:job_roles) { %w[teacher] }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ job_roles: job_roles })
      end
    end

    context "when a value is empty" do
      let(:job_roles) { [] }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ keyword: keyword })
      end
    end

    context "when radius is present" do
      let(:radius) { "10" }

      context "when location is not present" do
        it "omits radius value from the hash" do
          expect(subject.search_criteria_hash).to eq({ keyword: keyword })
        end
      end

      context "when location is present" do
        let(:location) { "North Nowhere" }

        it "includes radius value in the hash" do
          expect(subject.search_criteria_hash).to eq({ keyword: keyword, location: location, radius: "10" })
        end
      end
    end
  end

  describe "#validations" do
    let(:params) { {} }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to allow_value("valid@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }

    context "when job alert already exists" do
      let(:params) { { email: "test@email.com", frequency: "daily", keyword: "maths" } }

      before { allow(Subscription).to receive_message_chain(:where, :exists?).and_return(true) }

      it "validates uniqueness of job alert" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.duplicate_alert"))
      end
    end

    context "when default variant has been applied" do
      let(:params) { { variant: :default } }

      context "when no criteria are selected" do
        it "validates job alert criteria selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_criteria_selected"))
        end
      end

      context "when location and no other field are selected" do
        let(:params) { { variant: :default, location: "London" } }

        it "does not set no_location_and_other_criterion_selected error" do
          expect(subject.errors.messages[:base]).not_to include(I18n.t("subscriptions.errors.no_location_and_other_criterion_selected"))
        end
      end
    end

    context "when mandatory_location_and_one_other_field variant has been applied" do
      context "when location and no other field are selected" do
        let(:params) { { variant: :mandatory_location_and_one_other_field, location: "London" } }

        it "validates location_and_one_other_criterion_selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_and_other_criterion_selected"))
        end
      end

      context "when one other field selected but no location" do
        let(:params) { { variant: :mandatory_location_and_one_other_field, keyword: "Maths" } }

        it "validates location_and_one_other_criterion_selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_and_other_criterion_selected"))
        end
      end
    end
  end
end
