require 'pstore'
require 'mailer'

class MonthlyNotifier
  def initialize(monthly_reports, db)
    @monthly_reports = monthly_reports
    @db = db
  end

  def call
    emails_count = @monthly_reports.count
    @monthly_reports.each_with_index do |report, index|
      send_monthly_notification(report) if report.employee || true
      puts "Sent email #{index + 1}/#{emails_count}"
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
