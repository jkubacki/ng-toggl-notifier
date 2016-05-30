require 'mailer'

class DailyLunchNotifier
  def initialize(invalidity_reports)
    @invalidity_reports = invalidity_reports
  end

  def call
    invalidity_reports.each do |report|
      next if report.invalid_dinner_entries.empty?
      lunch_notification(report)
    end
  end

  private

  attr_reader :invalidity_reports

  def lunch_notification(report)
    Mailer.long_dinner(report.email, report: report)
  end
end
