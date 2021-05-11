class EqualOpportunitiesReport < ApplicationRecord
  belongs_to :vacancy

  def trigger_event
    Event.new.trigger(:equal_opportunities_report_published, event_data)
  end
end
