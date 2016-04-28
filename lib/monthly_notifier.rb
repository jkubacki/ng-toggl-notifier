require 'pstore'
require 'mailer'

class MonthlyNotifier
  def initialize(monthly_reports, db)
    @monthly_reports = monthly_reports
    @db = db
  end

  def call
    @monthly_reports.each do |report|
      send_monthly_notification(report)
    end
  end

  private

  def send_monthly_notification(report)
    Mailer.monthly_to_user(report.email, report: report)
    store_notification(report.email)
  end

  def store_notification(email)
    @db[:sent_monthly].insert(email: email, sent_at: Date.today)
  end
end
