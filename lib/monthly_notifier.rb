require 'pstore'
require 'mailer'

class MonthlyNotifier
  def call(monthly_reports)
    monthly_reports.each do |report|
      send_monthly_notification(report) if report.employee
    end
  end

  private

  def send_monthly_notification(report)
    Mailer.monthly_to_user(monthly_report.email, report: report)
  end
end
