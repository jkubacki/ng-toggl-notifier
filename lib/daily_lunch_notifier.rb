require 'mailer'

class DailyLunchNotifier
  def initialize(daily_reports)
    @daily_reports = daily_reports
  end

  def call
    daily_reports.each do |report|
      next if report.invalid_dinner_entries.empty?
      lunch_notification(report)
    end
  end

  private

  attr_reader :daily_reports

  def lunch_notification(report)
    Mailer.long_dinner(report.email, report: report)
  end
end
