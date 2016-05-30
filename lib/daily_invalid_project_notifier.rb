require 'mailer'

class DailyInvalidProjectNotifier
  def initialize(daily_reports)
    @daily_reports = daily_reports
  end

  def call
    daily_reports.each do |report|
      next if report.invalid_project_entries.empty?
      invalid_project_notification(report)
    end
  end

  private

  attr_reader :daily_reports

  def invalid_project_notification(report)
    Mailer.empty_project(report.email, report: report)
  end
end
