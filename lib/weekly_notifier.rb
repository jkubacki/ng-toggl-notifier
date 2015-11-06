class WeeklyNotifier
  WEEKLY_MAX_HOURS = 40

  attr_reader :weekly_reports

  def initialize(weekly_reports)
    @weekly_reports = weekly_reports
  end

  def call
    send_office_notification
  end

  private

  def reports_with_overtime
    @reports_with_overtime ||= weekly_reports.select do |report|
      report.total_hours > WEEKLY_MAX_HOURS
    end
  end

  def send_office_notification
    return if reports_with_overtime.empty?
    reports_by_user_name = reports_with_overtime.sort {|x, y| x.user_name <=> y.user_name }
    Mailer.weekly_to_office(reports: reports_by_user_name)
  end
end
