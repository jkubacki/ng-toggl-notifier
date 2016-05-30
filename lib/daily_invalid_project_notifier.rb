require 'mailer'

class DailyInvalidProjectNotifier
  def initialize(invalidity_reports)
    @invalidity_reports = invalidity_reports
  end

  def call
    invalidity_reports.each do |report|
      next if report.invalid_project_entries.empty?
      invalid_project_notification(report)
    end
  end

  private

  attr_reader :invalidity_reports

  def invalid_project_notification(report)
    Mailer.empty_project(report.email, report: report)
  end
end
