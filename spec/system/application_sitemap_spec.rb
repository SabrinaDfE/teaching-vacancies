require "rails_helper"
RSpec.describe "Application sitemap" do
  context "sitemap.xml" do
    scenario "generates a sitemap of the application" do
      published_jobs = (1..4).map { |i| create(:vacancy, :published, job_title: "Title#{i}") }
      expired_jobs = create_list(:vacancy, 2, :expired).each { |j| j.save(validate: false) }

      visit sitemap_path(format: :xml)
      document = Nokogiri::XML::Document.parse(body)
      nodes = document.search("url")

      expect(nodes.count).to eq(288)
      expect(nodes.search("loc[text()='#{root_url(protocol: 'https')}']").text)
        .to eq(root_url(protocol: "https"))

      published_jobs.each do |published_job|
        expect(nodes.search("loc:contains('#{job_path(published_job, protocol: 'https')}')").text)
          .to eq(job_url(published_job, protocol: "https"))
      end

      expired_jobs.each do |expired_job|
        expect(nodes.search("loc:contains('#{job_path(expired_job, protocol: 'https')}')").text).to eq("")
      end

      ALL_IMPORTED_LOCATIONS.each do |location|
        url = location_url(location.parameterize, protocol: "https")
        expect(nodes.search("loc:contains('#{url}')").map(&:text)).to include(url)
      end

      SUBJECT_OPTIONS.map(&:first).each do |subject|
        url = subject_url(subject.parameterize, protocol: "https")
        expect(nodes.search("loc:contains('#{url}')").map(&:text)).to include(url)
      end

      Vacancy.job_roles.each_key do |job_role|
        url = job_role_url(job_role.dasherize, protocol: "https")
        expect(nodes.search("loc:contains('#{url}')").map(&:text)).to include(url)
      end

      School.available_readable_phases.each do |phase|
        url = education_phase_url(phase.parameterize, protocol: "https")
        expect(nodes.search("loc:contains('#{url}')").map(&:text)).to include(url)
      end

      expect(nodes.search("loc:contains('#{page_url('terms-and-conditions', protocol: 'https')}')").text)
        .to eq(page_url("terms-and-conditions", protocol: "https"))
      expect(nodes.search("loc:contains('#{page_url('cookies', protocol: 'https')}')").text)
        .to eq(page_url("cookies", protocol: "https"))
      expect(nodes.search("loc:contains('#{page_url('privacy-policy', protocol: 'https')}')").text)
        .to eq(page_url("privacy-policy", protocol: "https"))
      expect(nodes.search("loc:contains('#{page_url('accessibility', protocol: 'https')}')").text)
        .to eq(page_url("accessibility", protocol: "https"))
    end
  end
end
